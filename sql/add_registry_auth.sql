-- Converts the registry (experiments/checkins) from public-writable/public-readable
-- (anyone, no login, could read or write any row) to per-user private data:
-- self-signup accounts, each person's institution recorded, and each person can
-- only ever see their OWN experiments/checkins -- never another lab's, published
-- or not. The catalog (known_safe_harbors) is untouched -- stays fully public.

-- STEP 1: profiles table -- one row per signed-up user, holds institution.
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  institution text not null,
  display_name text,
  created_at timestamptz default now()
);
alter table profiles enable row level security;

-- A user can only see/edit their own profile row -- no directory of other users.
drop policy if exists "own profile select" on profiles;
create policy "own profile select" on profiles for select using (auth.uid() = id);
drop policy if exists "own profile insert" on profiles;
create policy "own profile insert" on profiles for insert with check (auth.uid() = id);
drop policy if exists "own profile update" on profiles;
create policy "own profile update" on profiles for update using (auth.uid() = id);

-- STEP 2: add ownership to experiments.
alter table experiments add column if not exists user_id uuid references auth.users(id);

-- Server-side enforced ownership: whatever the client sends for user_id (or
-- omits) gets overwritten with the actual logged-in user. Prevents anyone from
-- inserting rows under someone else's name even if they tamper with the payload.
create or replace function set_experiment_owner()
returns trigger as $$
begin
  new.user_id := auth.uid();
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_set_experiment_owner on experiments;
create trigger trg_set_experiment_owner
  before insert on experiments
  for each row execute function set_experiment_owner();

-- STEP 3: wipe every existing policy on experiments/checkins (they were the old
-- "public, no login" policies -- names unknown/inconsistent, so drop generically
-- rather than guessing) and replace with owner-only access.
do $$
declare pol record;
begin
  for pol in select policyname from pg_policies where tablename = 'experiments' loop
    execute format('drop policy if exists %I on experiments', pol.policyname);
  end loop;
  for pol in select policyname from pg_policies where tablename = 'checkins' loop
    execute format('drop policy if exists %I on checkins', pol.policyname);
  end loop;
end $$;

alter table experiments enable row level security;
alter table checkins enable row level security;

-- Must be logged in to do anything; can only ever touch your own rows.
create policy "own experiments select" on experiments for select using (auth.uid() = user_id);
create policy "own experiments insert" on experiments for insert with check (auth.uid() is not null);
-- no update/delete policy on purpose -- registry entries are an append-only log,
-- matching the existing check-in-over-time design (correct a mistake with a new
-- check-in, don't rewrite history).

-- checkins has no user_id of its own -- ownership flows through the parent
-- experiment, so the policy checks that the referenced experiment belongs to you.
create policy "own checkins select" on checkins for select
  using (experiment_id in (select id from experiments where user_id = auth.uid()));
create policy "own checkins insert" on checkins for insert
  with check (experiment_id in (select id from experiments where user_id = auth.uid()));

-- Sanity check after running -- should show only the new owner-scoped policies:
-- select tablename, policyname, cmd from pg_policies where tablename in ('experiments','checkins','profiles');
