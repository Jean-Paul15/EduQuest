alter table profiles enable row level security;
alter table ticket_codes enable row level security;
alter table app_events enable row level security;
alter table learning_progress enable row level security;
alter table resources enable row level security;
alter table quizzes enable row level security;
alter table exam_papers enable row level security;
alter table live_classes enable row level security;
alter table contests enable row level security;
alter table contest_entries enable row level security;
alter table events enable row level security;
alter table event_registrations enable row level security;

create or replace function get_user_role(uid uuid)
returns text language sql stable
as $$ select role from profiles where id = uid; $$;

create or replace function is_admin_user(uid uuid default auth.uid())
returns boolean language sql stable
as $$ select exists(select 1 from profiles where id = uid and role = 'admin'); $$;

create or replace function has_scope_access(target_scope jsonb, uid uuid default auth.uid())
returns boolean language plpgsql stable
as $$
declare v_tier text := 'FREE';
begin
  if uid is null then return false; end if;
  if is_admin_user(uid) then return true; end if;
  if coalesce(target_scope, '{}'::jsonb) = '{}'::jsonb then return true; end if;
  select tp.ticket_type into v_tier
  from ticket_codes tc join ticket_products tp on tp.id = tc.product_id
  where tc.activated_by = uid and tc.expires_at > now()
  order by tc.expires_at desc limit 1;
  return v_tier = 'FULL';
end; $$;

drop policy if exists profiles_self_select on profiles;
create policy profiles_self_select on profiles
for select using (id = auth.uid() or is_admin_user(auth.uid()));
drop policy if exists profiles_self_update on profiles;
create policy profiles_self_update on profiles
for update using (id = auth.uid() or is_admin_user(auth.uid()))
with check (id = auth.uid() or is_admin_user(auth.uid()));
drop policy if exists ticket_codes_self_select on ticket_codes;
create policy ticket_codes_self_select on ticket_codes
for select using (activated_by = auth.uid() or is_admin_user(auth.uid()));
drop policy if exists app_events_insert_self on app_events;
create policy app_events_insert_self on app_events
for insert with check (profile_id = auth.uid());
drop policy if exists learning_progress_all_self on learning_progress;
create policy learning_progress_all_self on learning_progress
for all using (profile_id = auth.uid() or is_admin_user(auth.uid()))
with check (profile_id = auth.uid() or is_admin_user(auth.uid()));
drop policy if exists resources_access_select on resources;
create policy resources_access_select on resources
for select using (published = true and has_scope_access(access_scope));
drop policy if exists quizzes_access_select on quizzes;
create policy quizzes_access_select on quizzes
for select using (published = true and has_scope_access(access_scope));
drop policy if exists exam_papers_access_select on exam_papers;
create policy exam_papers_access_select on exam_papers
for select using (has_scope_access(access_scope));
drop policy if exists live_classes_access_select on live_classes;
create policy live_classes_access_select on live_classes
for select using (has_scope_access(access_scope));
drop policy if exists contests_access_select on contests;
create policy contests_access_select on contests
for select using (has_scope_access(access_scope));
drop policy if exists contest_entries_self_all on contest_entries;
create policy contest_entries_self_all on contest_entries
for all using (profile_id = auth.uid() or is_admin_user(auth.uid()))
with check (profile_id = auth.uid() or is_admin_user(auth.uid()));
drop policy if exists events_access_select on events;
create policy events_access_select on events
for select using (has_scope_access(access_scope));
drop policy if exists event_regs_self_all on event_registrations;
create policy event_regs_self_all on event_registrations
for all using (profile_id = auth.uid() or is_admin_user(auth.uid()))
with check (profile_id = auth.uid() or is_admin_user(auth.uid()));
