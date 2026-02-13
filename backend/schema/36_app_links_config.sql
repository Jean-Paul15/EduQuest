insert into app_config(key, value) values
(
  'app_links',
  jsonb_build_object(
    'support_url', 'https://example.com/support',
    'ticket_shop_url', 'https://example.com/tickets'
  )
)
on conflict (key) do update
set value = excluded.value, updated_at = now();

-- Optionnel: exemple de promo "acces ouvert a tous"
-- insert into access_campaigns(
--   country_id, name, campaign_type, target_filter, access_scope,
--   starts_at, ends_at, priority, active
-- )
-- select id, 'Promo rentrée', 'FREE_ALL', '{}'::jsonb, '{"all":true}'::jsonb,
--        now(), now() + interval '30 days', 10, true
-- from countries where code = 'TG'
-- on conflict do nothing;
