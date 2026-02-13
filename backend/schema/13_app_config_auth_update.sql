create table if not exists app_config (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

insert into app_config(key, value) values
('auth_options', '{"google":true,"apple":true,"email_password":true}'::jsonb)
on conflict (key) do update set value = excluded.value, updated_at = now();

insert into app_config(key, value) values
('app_update_policy', '{
  "enabled": true,
  "message": "Une mise à jour est obligatoire pour continuer.",
  "enforce_exact_match": true,
  "android": {"min_version":"1.0.0","min_build_number":1,"latest_version":"1.0.0","latest_build_number":1,"force_update":false,"store_url":""},
  "ios": {"min_version":"1.0.0","min_build_number":1,"latest_version":"1.0.0","latest_build_number":1,"force_update":false,"store_url":""}
}'::jsonb)
on conflict (key) do nothing;

insert into app_config(key, value) values
('hub_modules', '{"live":true,"contests":true,"events":true,"surveys":true,"referral":true,"market":true,"leaderboard":true,"orientation":true}'::jsonb)
on conflict (key) do nothing;

alter table app_config enable row level security;
drop policy if exists app_config_read_auth on app_config;
create policy app_config_read_auth on app_config for select using (auth.uid() is not null);
