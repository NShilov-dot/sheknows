-- Self-service account deletion (Apple App Store Guideline 5.1.1(v): apps that
-- let users create an account must let them delete it in-app).
--
-- A security-definer function so an authenticated user can delete only their
-- own auth.users row. The FK `on delete cascade` on profiles and tasks removes
-- their data, and the auth schema cascades identities/sessions/refresh tokens.
--
-- ponytail: deletes auth.users directly instead of via the Admin API. Simpler
-- (no Edge Function, no service_role key in the app) and complete for a
-- standard Supabase project. If you rely on custom auth hooks or want the
-- officially blessed path, replace this with a `delete-account` Edge Function
-- that calls auth.admin.deleteUser() — the client only changes rpc() to
-- functions.invoke().
create or replace function public.delete_own_account()
returns void
language sql
security definer
set search_path = ''
as $$
  delete from auth.users where id = auth.uid();
$$;

-- Only signed-in users may call it; auth.uid() scopes each caller to self.
revoke execute on function public.delete_own_account() from public;
grant execute on function public.delete_own_account() to authenticated;
