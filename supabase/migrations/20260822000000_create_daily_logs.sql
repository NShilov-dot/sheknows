-- Daily logs: one optional row per calendar day capturing mood, symptoms
-- and free-form notes. Unique per (user, day) so upserts are idempotent.
create table public.daily_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  log_date date not null,
  mood text check (
    mood in ('happy', 'calm', 'sad', 'irritable', 'anxious', 'energetic')
  ),
  symptoms text[] not null default '{}',
  notes text check (char_length(notes) <= 500),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  -- One row per user per day.
  constraint daily_logs_user_date_unique unique (user_id, log_date)
);

-- Fast per-user, per-day lookups (the unique constraint already creates a
-- btree index; this one supports "recent history" scans).
create index daily_logs_user_id_log_date_idx
  on public.daily_logs (user_id, log_date desc);

alter table public.daily_logs enable row level security;

create policy "Users read own daily logs"
  on public.daily_logs
  for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users insert own daily logs"
  on public.daily_logs
  for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users update own daily logs"
  on public.daily_logs
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users delete own daily logs"
  on public.daily_logs
  for delete
  to authenticated
  using (auth.uid() = user_id);
