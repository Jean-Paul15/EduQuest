create table if not exists notification_preferences (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id),
  revision_enabled boolean not null default true,
  contest_enabled boolean not null default true,
  event_enabled boolean not null default true,
  quiet_start time,
  quiet_end time,
  updated_at timestamptz not null default now(),
  unique(profile_id)
);

create or replace function get_user_role(uid uuid)
returns text language sql stable
as $$ select role from profiles where id = uid; $$;

alter table notification_preferences enable row level security;

drop policy if exists notif_prefs_self_all on notification_preferences;
create policy notif_prefs_self_all
on notification_preferences for all
using (profile_id = auth.uid() or get_user_role(auth.uid()) = 'admin')
with check (profile_id = auth.uid() or get_user_role(auth.uid()) = 'admin');
