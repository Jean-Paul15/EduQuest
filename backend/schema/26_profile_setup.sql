alter table profiles
  add column if not exists full_name text,
  add column if not exists avatar_url text,
  add column if not exists updated_at timestamptz not null default now();

drop policy if exists profiles_self_insert on profiles;
create policy profiles_self_insert on profiles
for insert with check (id = auth.uid() or is_admin_user(auth.uid()));
