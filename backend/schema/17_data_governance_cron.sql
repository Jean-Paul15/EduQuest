create table if not exists data_retention_policies (
  key text primary key,
  retention_days int not null,
  active boolean not null default true
);

create table if not exists compliance_audit_logs (
  id uuid primary key default gen_random_uuid(),
  action text not null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create or replace function inactive_student_ids(p_days int)
returns table(id uuid) language sql stable as $$
  select p.id
  from profiles p
  left join lateral (select max(event_time) as last_ev from app_events ae where ae.profile_id = p.id) ev on true
  where p.role = 'student' and coalesce(ev.last_ev, p.created_at) < now() - make_interval(days => p_days);
$$;

insert into data_retention_policies(key, retention_days, active) values
('app_events', 365, true),
('notification_preferences', 730, true),
('user_device_sessions_inactive', 90, true),
('inactive_user_purge_days', 180, true)
on conflict (key) do update set retention_days = excluded.retention_days, active = excluded.active;

create or replace function run_data_retention()
returns jsonb language plpgsql security definer
as $$
declare d_app int := 365; d_sess int := 90; d_user int := 180; n_app int := 0; n_sess int := 0; n_users int := 0;
begin
  select retention_days into d_app from data_retention_policies where key='app_events' and active=true;
  select retention_days into d_sess from data_retention_policies where key='user_device_sessions_inactive' and active=true;
  select retention_days into d_user from data_retention_policies where key='inactive_user_purge_days' and active=true;
  delete from app_events where event_time < now() - make_interval(days => d_app); get diagnostics n_app = row_count;
  delete from user_device_sessions where active=false and updated_at < now() - make_interval(days => d_sess); get diagnostics n_sess = row_count;
  delete from quest_completions where profile_id in (select id from inactive_student_ids(d_user));
  delete from gamification_profiles where profile_id in (select id from inactive_student_ids(d_user));
  delete from notification_preferences where profile_id in (select id from inactive_student_ids(d_user));
  delete from user_device_sessions where profile_id in (select id from inactive_student_ids(d_user));
  update ticket_codes set activated_by = null where activated_by in (select id from inactive_student_ids(d_user));
  delete from profiles where id in (select id from inactive_student_ids(d_user)); get diagnostics n_users = row_count;
  insert into compliance_audit_logs(action, details) values
  ('run_data_retention', jsonb_build_object('deleted_app_events', n_app, 'deleted_inactive_sessions', n_sess, 'purged_inactive_users', n_users));
  return jsonb_build_object('deleted_app_events', n_app, 'deleted_inactive_sessions', n_sess, 'purged_inactive_users', n_users);
end; $$;

do $$
begin
  if exists(select 1 from pg_extension where extname = 'pg_cron') then
    perform cron.schedule('eduquest_data_retention_daily', '15 3 * * *', $cron$select run_data_retention();$cron$);
  end if;
exception when others then null;
end $$;
