-- Tasks table: per-user to-do items demonstrating multi-row RLS and FK indexing.
create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null check (
    char_length(trim(title)) > 0
    and char_length(trim(title)) <= 200
  ),
  is_completed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Index the FK column for fast per-user queries and cascade deletes.
create index tasks_user_id_idx on public.tasks (user_id);

-- Composite index for the common "my tasks, newest first" query pattern.
create index tasks_user_id_created_at_idx on public.tasks (user_id, created_at desc);

alter table public.tasks enable row level security;

create policy "Users read own tasks"
  on public.tasks
  for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users insert own tasks"
  on public.tasks
  for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users update own tasks"
  on public.tasks
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users delete own tasks"
  on public.tasks
  for delete
  to authenticated
  using (auth.uid() = user_id);
