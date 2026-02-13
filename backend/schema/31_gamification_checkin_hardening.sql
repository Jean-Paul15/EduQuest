insert into daily_quests(code, label, xp_reward, active)
values('daily_checkin', 'Check-in quotidien', 20, true)
on conflict (code) do update set label=excluded.label, xp_reward=excluded.xp_reward, active=excluded.active;

create or replace function claim_daily_checkin()
returns jsonb language plpgsql security definer
as $$
declare v_uid uuid := auth.uid(); v_gam record; v_today date := current_date; v_qid uuid;
begin
  if v_uid is null then return jsonb_build_object('success',false,'message','Utilisateur non connecté.'); end if;
  insert into gamification_profiles(profile_id) values(v_uid) on conflict (profile_id) do nothing;
  select * into v_gam from gamification_profiles where profile_id = v_uid for update;
  if v_gam.last_checkin_date = v_today then
    return jsonb_build_object('success',false,'message','Check-in déjà effectué aujourd''hui.');
  end if;
  update gamification_profiles set
    streak_days = case when v_gam.last_checkin_date = v_today - 1 then v_gam.streak_days + 1 else 1 end,
    best_streak = greatest(v_gam.best_streak, case when v_gam.last_checkin_date = v_today - 1 then v_gam.streak_days + 1 else 1 end),
    xp = v_gam.xp + 20, level = greatest(1, ((v_gam.xp + 20) / 120) + 1),
    last_checkin_date = v_today, updated_at = now()
  where profile_id = v_uid;
  select id into v_qid from daily_quests where code='daily_checkin' and active=true limit 1;
  if v_qid is not null then
    insert into quest_completions(profile_id, quest_id, completed_on)
    values(v_uid, v_qid, v_today) on conflict do nothing;
  end if;
  return jsonb_build_object('success',true,'message','Check-in validé. +20 XP', 'xp_gain',20);
exception when others then
  return jsonb_build_object('success',false,'message','Erreur check-in, réessaie.');
end; $$;
