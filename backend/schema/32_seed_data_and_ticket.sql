do $$
declare
  v_uid uuid;
  v_country uuid;
  v_level uuid;
  v_series uuid;
  v_product uuid;
  v_ticket text;
begin
  select id into v_uid from auth.users where lower(email) = 'adoglijeanpaul@gmail.com' limit 1;
  if v_uid is null then
    raise exception 'Utilisateur auth.users introuvable pour adoglijeanpaul@gmail.com';
  end if;

  select id into v_country from countries where code = 'TG' limit 1;
  select id into v_level from education_levels where country_id = v_country and code = 'Terminale' limit 1;
  select id into v_series from series where education_level_id = v_level and code = 'D' limit 1;

  insert into profiles(id, role, country_id, education_level_id, series_id, full_name)
  values(v_uid, 'student', v_country, v_level, v_series, 'Jean-Paul')
  on conflict (id) do update set
    country_id = excluded.country_id,
    education_level_id = excluded.education_level_id,
    series_id = excluded.series_id,
    full_name = coalesce(profiles.full_name, excluded.full_name);

  insert into daily_quests(code, label, xp_reward, active) values
  ('daily_checkin', 'Check-in quotidien', 20, true),
  ('open_lesson', 'Ouvrir un cours', 10, true),
  ('complete_quiz', 'Terminer un QCM', 20, true),
  ('review_15min', 'Réviser 15 minutes', 15, true)
  on conflict (code) do update set label=excluded.label, xp_reward=excluded.xp_reward, active=excluded.active;

  select id into v_product from ticket_products
  where country_id = v_country and code = 'FULL_TERMINALE_30D' limit 1;
  if v_product is null then
    insert into ticket_products(country_id, code, ticket_type, duration_days, scope, active, base_education_level_id, allow_downward_access)
    values(v_country, 'FULL_TERMINALE_30D', 'FULL', 30, '{"all":true}'::jsonb, true, v_level, true)
    returning id into v_product;
  end if;

  if not exists(
    select 1 from ticket_codes tc join ticket_products tp on tp.id = tc.product_id
    where tc.activated_by = v_uid and tc.expires_at > now() and tp.ticket_type = 'FULL'
  ) then
    v_ticket := 'ADM' || upper(substr(md5(random()::text || clock_timestamp()::text),1,12));
    insert into ticket_codes(product_id, code, sold_to_phone, sold_at, activated_by, activated_at, expires_at)
    values(v_product, v_ticket, 'ADMIN_GRANT', now(), v_uid, now(), now() + interval '30 day');
  end if;
end $$;
