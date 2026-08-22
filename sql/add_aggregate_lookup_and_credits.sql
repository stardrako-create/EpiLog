-- Aggregate lookup (privacy-safe, embargo-gated) + automatic credit ledger.
-- Design spec: DESIGN_aggregate_access.md. Covers build-order steps 1 and 3
-- (lookup RPC + check-in-gated credits), skipping rate limiting (step 2) and
-- consumption-gating on the lookup itself for now -- earning comes first,
-- spending wired up separately once this is tested live.

-- ============================================================
-- STEP 1: embargo column + privacy-safe aggregate lookup RPC
-- ============================================================

-- When an experiment's checkins become eligible to count toward the
-- aggregate. Default 15 months from creation -- a reasoned starting point
-- for a typical locus-search-to-publication timeline, not a fitted number.
-- The owning lab can move this to now() any time to release early.
alter table experiments
  add column if not exists aggregate_visible_at timestamptz;

update experiments
  set aggregate_visible_at = created_at + interval '15 months'
  where aggregate_visible_at is null;

alter table experiments
  alter column aggregate_visible_at set default (now() + interval '15 months');

-- No trigger needed on top of the column default -- the app's insert
-- payload never sets aggregate_visible_at, so the default fires on every
-- new row automatically. (A trigger would only matter if some insert path
-- explicitly passed NULL, which none currently do.)

-- The lookup itself. One specific (locus, cell_model) pair per call --
-- no listing, no filters beyond these two, no raw rows, no user_id, no
-- notes. Only counts experiments that are past their embargo AND whose
-- owner opted into allow_aggregate_use (existing consent flag). Suppresses
-- the result entirely below n=3 -- a count of 1 or 2 is functionally a
-- raw-record leak.
create or replace function lookup_locus_aggregate(p_coords text, p_cell_model text)
returns table(n bigint, silenced_within_8w bigint)
security definer
set search_path = public
language sql
as $$
  with eligible as (
    select e.id
    from experiments e
    join profiles p on p.id = e.user_id
    where e.coords = p_coords
      and e.cell_model = p_cell_model
      and e.aggregate_visible_at <= now()
      and p.allow_aggregate_use = true
  ),
  latest_state as (
    select c.experiment_id,
           c.state,
           c.day,
           row_number() over (partition by c.experiment_id order by c.day desc) as rn
    from checkins c
    join eligible el on el.id = c.experiment_id
  )
  select
    count(distinct experiment_id) as n,
    count(distinct experiment_id) filter (
      where state = 'silenced' and day <= 56
    ) as silenced_within_8w
  from latest_state
  where rn = 1
  having count(distinct experiment_id) >= 3;
$$;

-- Callable by any logged-in user, not the public/anon role -- must be
-- authenticated to query it at all, even though it never returns
-- account-identifying data.
revoke all on function lookup_locus_aggregate(text, text) from public;
grant execute on function lookup_locus_aggregate(text, text) to authenticated;

-- ============================================================
-- STEP 3: automatic, check-in-gated credit ledger (the "scoreboard")
-- ============================================================

-- Ledger, not a single mutable counter -- gives you real history to show
-- a user ("earned 1 credit for X on this date"), not just a number, and
-- makes the balance computable/auditable (sum of amount) rather than
-- trusted blindly.
create table if not exists credit_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  experiment_id uuid references experiments(id) on delete set null,
  amount integer not null,
  reason text not null,
  created_at timestamptz default now()
);
alter table credit_ledger enable row level security;

-- Personal-only, matching every other table here -- no cross-account
-- visibility, no public leaderboard. A user can see their own history,
-- nothing else.
drop policy if exists "own credit ledger select" on credit_ledger;
create policy "own credit ledger select" on credit_ledger for select
  using (auth.uid() = user_id);
-- No insert/update/delete policy for regular users on purpose -- credits
-- are only ever granted by the trigger below (security definer), never
-- directly by client-side inserts.

-- "Fully uploaded" -- the completeness bar for an experiment to ever earn
-- credit. All the fields that meaningfully describe the experiment must be
-- present; notes stays optional (free text, not required for completeness).
create or replace function experiment_is_complete(exp experiments)
returns boolean
language sql
immutable
as $$
  select exp.species is not null and exp.species <> ''
     and exp.genome_build is not null and exp.genome_build <> ''
     and exp.coords is not null and exp.coords <> ''
     and exp.donor_age_days is not null
     and exp.tissue is not null and exp.tissue <> ''
     and exp.gene is not null and exp.gene <> ''
     and exp.edit_type is not null and exp.edit_type <> ''
     and exp.delivery is not null and exp.delivery <> ''
     and exp.cell_model is not null and exp.cell_model <> ''
     and exp.operator is not null and exp.operator <> '';
$$;

-- Fires on every checkin insert. Grants credit automatically -- no formal
-- request, no admin approval -- the first time a given experiment's
-- checkin satisfies both conditions: the experiment is fully filled out,
-- AND at least a minimum realistic interval has passed since the
-- experiment was created (14 days -- a reasoned floor against same-day
-- fabricated follow-ups, not a validated one). One credit per experiment,
-- not per checkin -- checks the ledger first so repeat checkins on the
-- same experiment don't farm repeat credits.
create or replace function grant_credit_on_qualifying_checkin()
returns trigger as $$
declare
  exp experiments;
  already_credited boolean;
begin
  select * into exp from experiments where id = new.experiment_id;

  if exp is null then
    return new;
  end if;

  if new.created_at is null then
    new.created_at := now();
  end if;

  if not experiment_is_complete(exp) then
    return new;
  end if;

  if (new.created_at - exp.created_at) < interval '14 days' then
    return new;
  end if;

  select exists(
    select 1 from credit_ledger
    where experiment_id = exp.id and reason = 'qualifying_checkin'
  ) into already_credited;

  if already_credited then
    return new;
  end if;

  insert into credit_ledger (user_id, experiment_id, amount, reason)
  values (exp.user_id, exp.id, 1, 'qualifying_checkin');

  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_grant_credit_on_checkin on checkins;
create trigger trg_grant_credit_on_checkin
  after insert on checkins
  for each row execute function grant_credit_on_qualifying_checkin();

-- Personal scoreboard -- current balance + a bit of shape for a "my
-- credits" view in the UI. Own-row RLS on credit_ledger already restricts
-- this to the calling user's own data even without an explicit filter,
-- but the RPC keeps the query out of client-side code.
create or replace function my_credit_balance()
returns table(balance bigint, total_earned bigint, entries_credited bigint)
security definer
set search_path = public
language sql
as $$
  select
    coalesce(sum(amount), 0) as balance,
    coalesce(sum(amount) filter (where amount > 0), 0) as total_earned,
    count(*) filter (where amount > 0) as entries_credited
  from credit_ledger
  where user_id = auth.uid();
$$;

revoke all on function my_credit_balance() from public;
grant execute on function my_credit_balance() to authenticated;

-- Sanity checks after running:
-- select tablename, policyname, cmd from pg_policies where tablename = 'credit_ledger';
-- select lookup_locus_aggregate('chr1:1-1000', 'HEK293T'); -- expect empty until real data exists
