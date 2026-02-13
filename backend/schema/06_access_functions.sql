create or replace function get_user_role(uid uuid)
returns text language sql stable
as $$ select role from profiles where id = uid; $$;

create or replace function resolve_access_scope(uid uuid default auth.uid())
returns jsonb language plpgsql stable
as $$
declare
  v_exp timestamptz;
  v_tier text := 'FREE';
  v_scope jsonb := '{}'::jsonb;
begin
  if uid is null then
    return jsonb_build_object('tier','ANON','has_access',false,'expires_at',null,'scope',v_scope);
  end if;
  if get_user_role(uid) = 'admin' then
    return jsonb_build_object('tier','ADMIN','has_access',true,'expires_at',null,'scope',jsonb_build_object('all',true));
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

create or replace function can_access_scope(target_scope jsonb, uid uuid default auth.uid())
returns boolean language plpgsql stable
as $$
declare v_state jsonb := resolve_access_scope(uid);
begin
  if coalesce((v_state->>'has_access')::boolean, false) = false then return false; end if;
  if target_scope = '{}'::jsonb then return true; end if;
  if coalesce((v_state->'scope'->>'all')::boolean, false) then return true; end if;
  return (v_state->>'tier') = 'FULL';
end; $$;

create or replace function activate_ticket_code(p_code text)
returns jsonb language plpgsql security definer
as $$
declare v_uid uuid := auth.uid(); v_ticket record;
begin
  if v_uid is null then return jsonb_build_object('success',false,'message','Utilisateur non connecte.'); end if;
  select tc.id, tc.activated_at, tp.duration_days into v_ticket
  from ticket_codes tc join ticket_products tp on tp.id = tc.product_id
  where tc.code = p_code and tp.active = true for update;
  if v_ticket.id is null then return jsonb_build_object('success',false,'message','Code invalide.'); end if;
  if v_ticket.activated_at is not null then return jsonb_build_object('success',false,'message','Code deja active.'); end if;
  update ticket_codes set activated_by = v_uid, activated_at = now(),
    expires_at = now() + make_interval(days => v_ticket.duration_days) where id = v_ticket.id;
  return jsonb_build_object('success',true,'message','Ticket active avec succes.');
end; $$;

revoke all on function activate_ticket_code(text) from public;
grant execute on function activate_ticket_code(text) to authenticated;

