create or replace function activate_ticket_code(p_code text)
returns jsonb language plpgsql security definer
as $$
declare v_uid uuid := auth.uid(); v_ticket record; v_level uuid; v_ref uuid;
begin
  if v_uid is null then return jsonb_build_object('success',false,'message','Utilisateur non connecté.'); end if;
  select tc.id, tc.activated_at, tc.product_id, tp.duration_days into v_ticket
  from ticket_codes tc join ticket_products tp on tp.id = tc.product_id
  where tc.code = p_code and tp.active = true for update;
  if v_ticket.id is null then return jsonb_build_object('success',false,'message','Code invalide.'); end if;
  if v_ticket.activated_at is not null then return jsonb_build_object('success',false,'message','Code déjà activé.'); end if;
  select education_level_id into v_level from profiles where id = v_uid;
  if v_level is not null and can_ticket_cover_level(v_ticket.product_id, v_level) = false then
    return jsonb_build_object('success',false,'message','Ticket non compatible avec ta classe actuelle.');
  end if;
  update ticket_codes set activated_by = v_uid, activated_at = now(),
    expires_at = now() + make_interval(days => v_ticket.duration_days) where id = v_ticket.id;
  select referrer_profile_id into v_ref from referral_uses where referred_profile_id = v_uid limit 1;
  if v_ref is not null then perform maybe_reward_referrer(v_ref); end if;
  return jsonb_build_object('success',true,'message','Ticket activé avec succès.');
end; $$;

grant execute on function maybe_reward_referrer(uuid) to authenticated;
grant execute on function referral_qualified_count(uuid) to authenticated;
