-- Opt-in sharing: each account's data is private by default (see
-- add_registry_auth.sql). This adds personal share links -- a user can
-- generate an unguessable link and send it to whoever they want; anyone
-- with that link (no account needed) can view that user's registry
-- read-only. Revoking the link kills access immediately. Nothing becomes
-- public by this -- a link only exists if the owner created it, and only
-- exposes that one owner's data, never anyone else's.

create table if not exists share_links (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  token uuid not null unique default gen_random_uuid(),
  label text,
  active boolean not null default true,
  created_at timestamptz default now()
);
alter table share_links enable row level security;

-- Owners manage only their own links -- can't see or revoke anyone else's.
drop policy if exists "own share links select" on share_links;
create policy "own share links select" on share_links for select using (auth.uid() = user_id);
drop policy if exists "own share links insert" on share_links;
create policy "own share links insert" on share_links for insert with check (auth.uid() = user_id);
drop policy if exists "own share links update" on share_links;
create policy "own share links update" on share_links for update using (auth.uid() = user_id);

-- The read path for a shared link: security definer means this function runs
-- with elevated rights internally, but it only ever returns the single
-- owner's data tied to a valid, active token -- callers (including anonymous
-- visitors with no account) never get broader access than that one grant.
create or replace function get_shared_experiments(p_token uuid)
returns table (
  id uuid, species text, genome_build text, coords text, donor_age_days int,
  tissue text, gene text, edit_type text, delivery text, cell_model text,
  operator text, notes text, created_at timestamptz,
  checkins jsonb
) as $$
  select
    e.id, e.species, e.genome_build, e.coords, e.donor_age_days, e.tissue,
    e.gene, e.edit_type, e.delivery, e.cell_model, e.operator, e.notes,
    e.created_at,
    coalesce(
      (select jsonb_agg(to_jsonb(c) - 'experiment_id' order by c.day)
       from checkins c where c.experiment_id = e.id),
      '[]'::jsonb
    ) as checkins
  from experiments e
  join share_links sl on sl.user_id = e.user_id
  where sl.token = p_token and sl.active = true;
$$ language sql security definer stable;

-- Anonymous (anon key) and logged-in users alike are allowed to CALL the
-- function -- the function itself is what restricts what comes back, not
-- table-level grants, so this is safe to leave open.
grant execute on function get_shared_experiments(uuid) to anon, authenticated;
