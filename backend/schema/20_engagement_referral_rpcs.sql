create table if not exists referral_uses (
  id uuid primary key default gen_random_uuid(),
  referrer_profile_id uuid not null references profiles(id),
  referred_profile_id uuid not null unique references profiles(id),
  referral_code text not null,
  created_at timestamptz not null default now()
);

alter table referral_links enable row level security;
alter table referral_uses enable row level security;
drop policy if exists referral_links_self on referral_links;
create policy referral_links_self on referral_links for all
using (profile_id = auth.uid() or get_user_role(auth.uid()) = 'admin')
with check (profile_id = auth.uid() or get_user_role(auth.uid()) = 'admin');
drop policy if exists referral_uses_self on referral_uses;
create policy referral_uses_self on referral_uses for select
using (referrer_profile_id = auth.uid() or referred_profile_id = auth.uid() or get_user_role(auth.uid()) = 'admin');

create or replace function has_required_ticket(p_required text, uid uuid default auth.uid())
returns boolean language plpgsql stable as $$
declare v_tier text := coalesce(resolve_access_scope(uid)->>'tier','FREE');
begin
  if p_required is null then return true; end if;
  if v_tier = 'ADMIN' then return true; end if;
  if p_required = 'HALF' then return v_tier in ('HALF','FULL'); end if;
  return v_tier = 'FULL';
end; $$;

create or replace function join_contest(p_contest_id uuid)
returns jsonb language plpgsql security definer as $$
declare v_uid uuid := auth.uid(); v_req text; v_scope jsonb;
begin
  if v_uid is null then return jsonb_build_object('success',false,'message','Utilisateur non connecté.'); end if;
  select required_ticket_type, access_scope into v_req, v_scope from contests where id = p_contest_id;
  if not found then return jsonb_build_object('success',false,'message','Concours introuvable.'); end if;
  if has_scope_access(coalesce(v_scope,'{}'::jsonb), v_uid) = false then return jsonb_build_object('success',false,'message','Concours non accessible.'); end if;
  if has_required_ticket(v_req, v_uid) = false then return jsonb_build_object('success',false,'message','Ticket insuffisant.'); end if;
  insert into contest_entries(contest_id, profile_id) values (p_contest_id, v_uid) on conflict do nothing;
  return jsonb_build_object('success',true,'message','Inscription concours confirmée.');
end; $$;

create or replace function join_event(p_event_id uuid)
returns jsonb language plpgsql security definer as $$
declare v_uid uuid := auth.uid(); v_req text; v_scope jsonb; v_pass text := upper(substr(md5(random()::text),1,8));
begin
  if v_uid is null then return jsonb_build_object('success',false,'message','Utilisateur non connecté.'); end if;
  select required_ticket_type, access_scope into v_req, v_scope from events where id = p_event_id;
  if not found then return jsonb_build_object('success',false,'message','Événement introuvable.'); end if;
  if has_scope_access(coalesce(v_scope,'{}'::jsonb), v_uid) = false then return jsonb_build_object('success',false,'message','Événement non accessible.'); end if;
  if has_required_ticket(v_req, v_uid) = false then return jsonb_build_object('success',false,'message','Ticket insuffisant.'); end if;
  insert into event_registrations(event_id, profile_id, pass_code) values (p_event_id, v_uid, v_pass) on conflict do nothing;
  return jsonb_build_object('success',true,'message','Inscription événement confirmée.');
end; $$;

create or replace function ensure_referral_code()
returns text language plpgsql security definer as $$
declare v_uid uuid := auth.uid(); v_code text;
begin
  if v_uid is null then return null; end if;
  select referral_code into v_code from referral_links where profile_id = v_uid limit 1;
  if v_code is not null then return v_code; end if;
  v_code := upper(substr(md5(v_uid::text || random()::text),1,8));
  insert into referral_links(profile_id, referral_code) values(v_uid, v_code) on conflict do nothing;
  return v_code;
end; $$;

create or replace function apply_referral_code(p_code text)
returns jsonb language plpgsql security definer as $$
declare v_uid uuid := auth.uid(); v_ref uuid;
begin
  if v_uid is null then return jsonb_build_object('success',false,'message','Utilisateur non connecté.'); end if;
  if exists(select 1 from referral_uses where referred_profile_id = v_uid) then return jsonb_build_object('success',false,'message','Parrainage déjà utilisé.'); end if;
  select profile_id into v_ref from referral_links where referral_code = upper(trim(p_code)) limit 1;
  if v_ref is null or v_ref = v_uid then return jsonb_build_object('success',false,'message','Code de parrainage invalide.'); end if;
  insert into referral_uses(referrer_profile_id, referred_profile_id, referral_code) values(v_ref, v_uid, upper(trim(p_code)));
  return jsonb_build_object('success',true,'message','Parrainage appliqué.');
end; $$;

grant execute on function join_contest(uuid) to authenticated;
grant execute on function join_event(uuid) to authenticated;
grant execute on function ensure_referral_code() to authenticated;
grant execute on function apply_referral_code(text) to authenticated;
