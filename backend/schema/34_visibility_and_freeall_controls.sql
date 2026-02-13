alter table contests add column if not exists is_visible boolean not null default true;
alter table events add column if not exists is_visible boolean not null default true;
alter table surveys add column if not exists is_visible boolean not null default true;
alter table live_classes add column if not exists is_visible boolean not null default true;

create or replace function resolve_access_scope(uid uuid default auth.uid())
returns jsonb language plpgsql stable
as $$
declare
  v_exp timestamptz;
  v_tier text := 'FREE';
  v_scope jsonb := '{}'::jsonb;
  v_country uuid;
begin
  if uid is null then return jsonb_build_object('tier','ANON','has_access',false,'expires_at',null,'scope',v_scope); end if;
  if get_user_role(uid) = 'admin' then return jsonb_build_object('tier','ADMIN','has_access',true,'expires_at',null,'scope',jsonb_build_object('all',true)); end if;
  select country_id into v_country from profiles where id = uid;
  if exists (
    select 1 from access_campaigns c
    where c.active = true and c.campaign_type = 'FREE_ALL'
      and now() between c.starts_at and c.ends_at
      and (c.country_id is null or c.country_id = v_country)
  ) then
    return jsonb_build_object('tier','CAMPAIGN_FREE','has_access',true,'expires_at',null,'scope',jsonb_build_object('all',true,'source','campaign'));
  end if;
  select max(expires_at) into v_exp from ticket_codes where activated_by = uid and expires_at > now();
  if v_exp is not null then
    select tp.ticket_type, tp.scope into v_tier, v_scope
    from ticket_codes tc join ticket_products tp on tp.id = tc.product_id
    where tc.activated_by = uid and tc.expires_at = v_exp limit 1;
    return jsonb_build_object('tier',v_tier,'has_access',true,'expires_at',v_exp,'scope',coalesce(v_scope,'{}'::jsonb));
  end if;
  return jsonb_build_object('tier','FREE','has_access',true,'expires_at',null,'scope','{}'::jsonb);
end; $$;

create or replace function has_scope_access(target_scope jsonb, uid uuid default auth.uid())
returns boolean language plpgsql stable
as $$
declare v_state jsonb := resolve_access_scope(uid);
begin
  if uid is null then return false; end if;
  if coalesce((v_state->>'has_access')::boolean, false) = false then return false; end if;
  if coalesce(target_scope, '{}'::jsonb) = '{}'::jsonb then return true; end if;
  if coalesce((v_state->'scope'->>'all')::boolean, false) then return true; end if;
  return (v_state->>'tier') = 'FULL';
end; $$;

create or replace function join_contest(p_contest_id uuid)
returns jsonb language plpgsql security definer as $$
declare v_uid uuid := auth.uid(); v_req text; v_scope jsonb;
begin
  if v_uid is null then return jsonb_build_object('success',false,'message','Utilisateur non connecté.'); end if;
  select required_ticket_type, access_scope into v_req, v_scope from contests where id = p_contest_id and is_visible = true;
  if not found then return jsonb_build_object('success',false,'message','Concours indisponible.'); end if;
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
  select required_ticket_type, access_scope into v_req, v_scope from events where id = p_event_id and is_visible = true;
  if not found then return jsonb_build_object('success',false,'message','Événement indisponible.'); end if;
  if has_scope_access(coalesce(v_scope,'{}'::jsonb), v_uid) = false then return jsonb_build_object('success',false,'message','Événement non accessible.'); end if;
  if has_required_ticket(v_req, v_uid) = false then return jsonb_build_object('success',false,'message','Ticket insuffisant.'); end if;
  insert into event_registrations(event_id, profile_id, pass_code) values (p_event_id, v_uid, v_pass) on conflict do nothing;
  return jsonb_build_object('success',true,'message','Inscription événement confirmée.');
end; $$;
