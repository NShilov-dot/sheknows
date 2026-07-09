-- Harden profiles RLS to match the tasks policies:
-- restrict to authenticated role and allow self-insert.
-- Safe to re-run against databases that already applied the original profiles migration.

drop policy if exists "Users read own profile" on public.profiles;
drop policy if exists "Users insert own profile" on public.profiles;
drop policy if exists "Users update own profile" on public.profiles;

create policy "Users read own profile"
  on public.profiles
  for select
  to authenticated
  using (auth.uid() = id);

create policy "Users insert own profile"
  on public.profiles
  for insert
  to authenticated
  with check (auth.uid() = id);

create policy "Users update own profile"
  on public.profiles
  for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);
