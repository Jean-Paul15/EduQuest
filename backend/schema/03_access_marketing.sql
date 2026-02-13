-- Access, tickets, campaigns, partnerships
create table if not exists ticket_products (
  id uuid primary key default gen_random_uuid(),
  country_id uuid not null references countries(id),
  code text unique not null,
  ticket_type text not null check (ticket_type in ('FULL','HALF')),
  duration_days int not null,
  scope jsonb not null default '{}'::jsonb,
  active boolean not null default true
);

create table if not exists ticket_codes (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references ticket_products(id),
  code text unique not null,
  sold_to_phone text,
  sold_at timestamptz,
  activated_by uuid references profiles(id),
  activated_at timestamptz,
  expires_at timestamptz
);

create table if not exists access_campaigns (
  id uuid primary key default gen_random_uuid(),
  country_id uuid references countries(id),
  name text not null,
  campaign_type text not null check (campaign_type in ('FREE_ALL','FREE_PARTIAL','DISCOUNTED_TICKET','BONUS_DAYS')),
  target_filter jsonb not null default '{}'::jsonb,
  access_scope jsonb not null default '{}'::jsonb,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  priority int not null default 100,
  active boolean not null default true
);

create table if not exists partner_schools (
  id uuid primary key default gen_random_uuid(),
  country_id uuid not null references countries(id),
  name text not null,
  external_ref text unique,
  active boolean not null default true
);

create table if not exists partner_contracts (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references partner_schools(id),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  access_scope jsonb not null default '{}'::jsonb,
  ticket_discount_percent numeric(5,2) default 0
);

create table if not exists access_grants (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id),
  source text not null check (source in ('ticket','campaign','partnership','admin')),
  source_id uuid,
  scope jsonb not null default '{}'::jsonb,
  starts_at timestamptz not null default now(),
  ends_at timestamptz
);

