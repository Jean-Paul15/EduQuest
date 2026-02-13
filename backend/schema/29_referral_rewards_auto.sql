create table if not exists referral_reward_events (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id),
  milestone int not null,
  qualified_count int not null,
  reward_ticket_code_id uuid references ticket_codes(id),
  rewarded_at timestamptz not null default now(),
  unique(profile_id, milestone)
);

create or replace function referral_qualified_count(p_referrer uuid)
returns int language sql stable as $$
  select count(distinct ru.referred_profile_id)::int
  from referral_uses ru
  where ru.referrer_profile_id = p_referrer
    and exists (
      select 1 from ticket_codes tc
      where tc.activated_by = ru.referred_profile_id
        and tc.activated_at is not null
    );
$$;

create or replace function maybe_reward_referrer(p_referrer uuid)
returns jsonb language plpgsql security definer as $$
declare v_q int := referral_qualified_count(p_referrer); v_country uuid; v_product uuid; v_code_id uuid;
declare v_end timestamptz; v_code text;
begin
  if p_referrer is null then return jsonb_build_object('success',false,'message','Parrain introuvable.'); end if;
  if v_q < 5 then return jsonb_build_object('success',false,'message','Seuil non atteint.','qualified',v_q); end if;
  if exists(select 1 from referral_reward_events where profile_id=p_referrer and milestone=5) then
    return jsonb_build_object('success',true,'message','Récompense déjà attribuée.','qualified',v_q);
  end if;
  select country_id into v_country from profiles where id = p_referrer;
  select id into v_product from ticket_products
  where country_id = v_country and code = 'REF_FULL_BONUS_30D' limit 1;
  if v_product is null then
    insert into ticket_products(country_id, code, ticket_type, duration_days, scope, active)
    values(v_country, 'REF_FULL_BONUS_30D', 'FULL', 30, '{"all":true}'::jsonb, true)
    returning id into v_product;
  end if;
  select coalesce(max(expires_at), now()) + interval '30 day' into v_end
  from ticket_codes where activated_by = p_referrer and expires_at > now();
  v_code := 'REF' || upper(substr(md5(random()::text || clock_timestamp()::text),1,12));
  insert into ticket_codes(product_id, code, sold_to_phone, sold_at, activated_by, activated_at, expires_at)
  values(v_product, v_code, 'REFERRAL_REWARD', now(), p_referrer, now(), v_end)
  returning id into v_code_id;
  insert into referral_reward_events(profile_id, milestone, qualified_count, reward_ticket_code_id)
  values(p_referrer, 5, v_q, v_code_id);
  return jsonb_build_object('success',true,'message','Bonus FULL +30 jours attribué.','qualified',v_q);
end; $$;
