-- Symptom logs: one row per logged symptom at a precise time. Unlike day_logs
-- (one row per day), multiple entries per day are expected, so there is no
-- per-day unique constraint.
create table public.symptom_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  symptom_type text not null check (
    symptom_type in (
      'cramps', 'headache', 'backache', 'chestPain',
      'irritability', 'sadness', 'anxiety', 'moodSwings',
      'fatigue', 'energy', 'insomnia',
      'wateryDischarge', 'mucusDischarge', 'spottingDischarge',
      'acne', 'bloating', 'nausea', 'lowLibido', 'highLibido'
    )
  ),
  severity text not null check (
    severity in ('none', 'mild', 'moderate', 'severe')
  ),
  logged_at timestamptz not null,
  notes text check (char_length(notes) <= 300),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Index the FK column for fast per-user queries and cascade deletes.
create index symptom_logs_user_id_idx on public.symptom_logs (user_id);

-- Composite index for the common "my symptoms, newest first" query pattern.
create index symptom_logs_user_id_logged_at_idx
  on public.symptom_logs (user_id, logged_at desc);

alter table public.symptom_logs enable row level security;

create policy "Users read own symptom logs"
  on public.symptom_logs
  for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users insert own symptom logs"
  on public.symptom_logs
  for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users update own symptom logs"
  on public.symptom_logs
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users delete own symptom logs"
  on public.symptom_logs
  for delete
  to authenticated
  using (auth.uid() = user_id);
