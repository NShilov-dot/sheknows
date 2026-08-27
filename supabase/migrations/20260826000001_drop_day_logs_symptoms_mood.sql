-- Symptoms and mood moved to the dedicated `symptom_logs` table, which records
-- severity and a precise time per entry. Drop the old day-level flag columns
-- from `day_logs`; it now tracks only intimacy and a note.
--
-- Destructive: any values in these columns are discarded. Safe here because the
-- app is pre-release with no production data to preserve.
alter table public.day_logs
  drop column if exists symptoms,
  drop column if exists mood;
