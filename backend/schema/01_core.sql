-- Core taxonomy and users
create extension if not exists pgcrypto;

create table if not exists countries (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name text not null
);

create table if not exists education_levels (
  id uuid primary key default gen_random_uuid(),
  country_id uuid not null references countries(id),
  code text not null,
  label text not null,
  is_active boolean not null default true,
  is_exam_level boolean not null default false,
  exam_name text,
  unique(country_id, code)
);

create table if not exists series (
  id uuid primary key default gen_random_uuid(),
  education_level_id uuid not null references education_levels(id),
  code text not null,
  label text not null,
  is_active boolean not null default true,
  unique(education_level_id, code)
);

create table if not exists subjects (
  id uuid primary key default gen_random_uuid(),
  country_id uuid not null references countries(id),
  code text not null,
  label text not null,
  unique(country_id, code)
);

create table if not exists series_subjects (
  id uuid primary key default gen_random_uuid(),
  series_id uuid not null references series(id),
  subject_id uuid not null references subjects(id),
  coefficient numeric(5,2),
  unique(series_id, subject_id)
);

create table if not exists profiles (
  id uuid primary key references auth.users(id),
  role text not null check (role in ('admin','editor','teacher','student','partner_manager')),
  country_id uuid references countries(id),
  education_level_id uuid references education_levels(id),
  series_id uuid references series(id),
  school_name text,
  created_at timestamptz not null default now()
);
