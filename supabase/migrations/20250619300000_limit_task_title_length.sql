-- Cap task titles at 200 characters (matches kTaskTitleMaxLength in the app).
-- Safe to re-run against databases that already applied the updated create_tasks migration.

alter table public.tasks
  drop constraint if exists tasks_title_check;

alter table public.tasks
  add constraint tasks_title_check
  check (
    char_length(trim(title)) > 0
    and char_length(trim(title)) <= 200
  );
