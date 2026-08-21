-- Period logs: one row per menstrual period episode.
-- An ongoing period has a NULL end_date.
create table public.period_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  start_date date not null,
  end_date date,
  flow text check (flow in ('light', 'medium', 'heavy')),
  notes text check (char_length(notes) <= 500),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  -- A finished period must end on or after its start date.
  constraint period_logs_end_after_start check (
    end_date is null or end_date >= start_date
  )
);

-- Index the FK column for fast per-user queries and cascade deletes.
create index period_logs_user_id_idx on public.period_logs (user_id);

-- Composite index for the common "my periods, newest first" query pattern.
create index period_logs_user_id_start_date_idx
  on public.period_logs (user_id, start_date desc);

-- Prevent overlapping periods per user. Ongoing periods (NULL end_date)
-- extend indefinitely, so a new period cannot start until the previous
-- one is ended. Ranges are [start, end+1) so back-to-back periods
-- (next start == previous end) are allowed.
create extension if not exists btree_gist;

alter table public.period_logs
  add constraint period_logs_no_overlap
  exclude using gist (
    user_id with =,
    daterange(start_date, coalesce(end_date, 'infinity'::date), '[)') with &&
  );

alter table public.period_logs enable row level security;

create policy "Users read own period logs"
  on public.period_logs
  for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users insert own period logs"
  on public.period_logs
  for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users update own period logs"
  on public.period_logs
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users delete own period logs"
  on public.period_logs
  for delete
  to authenticated
  using (auth.uid() = user_id);
