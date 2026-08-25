-- Day logs: one row per user per calendar day for tracking that is separate
-- from the period itself — intimacy, symptoms, mood, and a free-text note.
create table public.day_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  log_date date not null,
  sexual_activity text check (sexual_activity in ('protected', 'unprotected')),
  symptoms text[] not null default '{}',
  mood text,
  notes text check (char_length(notes) <= 300),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  -- One log per user per day; upserts key on this pair.
  constraint day_logs_user_date_unique unique (user_id, log_date)
);

-- Index the FK column for fast per-user queries and cascade deletes.
create index day_logs_user_id_idx on public.day_logs (user_id);

-- Composite index for the common "my days, newest first" query pattern.
create index day_logs_user_id_log_date_idx
  on public.day_logs (user_id, log_date desc);

alter table public.day_logs enable row level security;

create policy "Users read own day logs"
  on public.day_logs
  for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users insert own day logs"
  on public.day_logs
  for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users update own day logs"
  on public.day_logs
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users delete own day logs"
  on public.day_logs
  for delete
  to authenticated
  using (auth.uid() = user_id);
