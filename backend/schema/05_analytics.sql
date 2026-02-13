-- Analytics and orientation
create table if not exists app_events (
  id bigserial primary key,
  profile_id uuid references profiles(id),
  event_name text not null,
  event_time timestamptz not null default now(),
  platform text not null,
  app_version text,
  is_offline boolean not null default false,
  country_code text,
  education_level_code text,
  series_code text,
  payload jsonb not null default '{}'::jsonb
);

create index if not exists idx_app_events_name_time on app_events(event_name, event_time desc);
create index if not exists idx_app_events_profile_time on app_events(profile_id, event_time desc);

create table if not exists learning_progress (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id),
  chapter_id uuid not null references chapters(id),
  completion_percent numeric(5,2) not null default 0,
  last_activity_at timestamptz not null default now(),
  unique(profile_id, chapter_id)
);

create table if not exists orientation_sessions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id),
  status text not null check (status in ('started','completed','cancelled')),
  answers jsonb not null default '{}'::jsonb,
  recommendation jsonb,
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

create table if not exists leaderboards (
  id uuid primary key default gen_random_uuid(),
  country_id uuid references countries(id),
  period_key text not null,
  metric text not null,
  ranking jsonb not null,
  generated_at timestamptz not null default now(),
  unique(country_id, period_key, metric)
);

