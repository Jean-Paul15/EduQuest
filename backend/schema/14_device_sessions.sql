create table if not exists user_device_sessions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id),
  device_id text not null,
  session_token_hash text not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(profile_id, device_id)
);

alter table user_device_sessions enable row level security;
drop policy if exists uds_self_select on user_device_sessions;
create policy uds_self_select on user_device_sessions for select
using (profile_id = auth.uid() or get_user_role(auth.uid()) = 'admin');

create or replace function claim_device_session(p_device_id text, p_session_token_hash text)
returns jsonb language plpgsql security definer
as $$
declare v_uid uuid := auth.uid();
begin
  if v_uid is null then return jsonb_build_object('success',false,'message','Utilisateur non connecté.'); end if;
  update user_device_sessions set active = false, updated_at = now() where profile_id = v_uid and device_id <> p_device_id;
  insert into user_device_sessions(profile_id, device_id, session_token_hash, active, updated_at)
  values(v_uid, p_device_id, p_session_token_hash, true, now())
  on conflict (profile_id, device_id) do update set session_token_hash = excluded.session_token_hash, active = true, updated_at = now();
  return jsonb_build_object('success',true);
end; $$;

create or replace function is_device_session_valid(p_device_id text, p_session_token_hash text)
returns boolean language sql security definer
as $$ select exists(
  select 1 from user_device_sessions
  where profile_id = auth.uid() and device_id = p_device_id and session_token_hash = p_session_token_hash and active = true
); $$;

revoke all on function claim_device_session(text, text) from public;
grant execute on function claim_device_session(text, text) to authenticated;
revoke all on function is_device_session_valid(text, text) from public;
grant execute on function is_device_session_valid(text, text) to authenticated;

