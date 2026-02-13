-- Contests, events, referrals, surveys, marketplace
create table if not exists contests (
  id uuid primary key default gen_random_uuid(),
  country_id uuid not null references countries(id),
  title text not null,
  rules_md text not null,
  eligibility_scope jsonb not null default '{}'::jsonb,
  access_scope jsonb not null default '{}'::jsonb,
  required_ticket_type text check (required_ticket_type in ('FULL','HALF')),
  starts_at timestamptz not null,
  ends_at timestamptz not null
);

create table if not exists contest_entries (
  id uuid primary key default gen_random_uuid(),
  contest_id uuid not null references contests(id),
  profile_id uuid not null references profiles(id),
  score numeric(10,2) default 0,
  rank int,
  created_at timestamptz not null default now(),
  unique(contest_id, profile_id)
);

create table if not exists events (
  id uuid primary key default gen_random_uuid(),
  country_id uuid references countries(id),
  title text not null,
  event_type text not null,
  access_scope jsonb not null default '{}'::jsonb,
  required_ticket_type text check (required_ticket_type in ('FULL','HALF')),
  starts_at timestamptz not null,
  venue text,
  external_ticket_url text
);

create table if not exists event_registrations (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events(id),
  profile_id uuid not null references profiles(id),
  pass_code text unique,
  created_at timestamptz not null default now(),
  unique(event_id, profile_id)
);

create table if not exists referral_links (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id),
  referral_code text unique not null,
  created_at timestamptz not null default now()
);

create table if not exists surveys (
  id uuid primary key default gen_random_uuid(),
  country_id uuid references countries(id),
  title text not null,
  target_scope jsonb not null default '{}'::jsonb,
  starts_at timestamptz not null,
  ends_at timestamptz not null
);

create table if not exists marketplace_items (
  id uuid primary key default gen_random_uuid(),
  country_id uuid references countries(id),
  title text not null,
  item_type text not null check (item_type in ('book','kit','ad_slot')),
  price_label text,
  external_checkout_url text not null,
  active boolean not null default true
);
