-- Learning content and assessments
create table if not exists chapters (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references subjects(id),
  education_level_id uuid not null references education_levels(id),
  title text not null,
  position int not null default 0
);

create table if not exists resources (
  id uuid primary key default gen_random_uuid(),
  chapter_id uuid not null references chapters(id),
  type text not null check (type in ('pdf','video','youtube','exercise_set','summary')),
  title text not null,
  storage_path text,
  external_url text,
  is_downloadable boolean not null default true,
  access_scope jsonb not null default '{}'::jsonb,
  version text not null default '1.0.0',
  published boolean not null default false
);

alter table resources
  drop constraint if exists resources_video_source_check;

alter table resources
  add constraint resources_video_source_check
  check (
    (type = 'youtube' and external_url is not null and storage_path is null)
    or
    (type = 'video' and (external_url is not null or storage_path is not null))
    or
    (type in ('pdf','exercise_set','summary'))
  );

create table if not exists quizzes (
  id uuid primary key default gen_random_uuid(),
  chapter_id uuid not null references chapters(id),
  title text not null,
  access_scope jsonb not null default '{}'::jsonb,
  published boolean not null default false
);

create table if not exists quiz_questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references quizzes(id),
  type text not null check (type in ('mcq','short')),
  prompt text not null,
  answer_key jsonb
);

create table if not exists exam_papers (
  id uuid primary key default gen_random_uuid(),
  country_id uuid not null references countries(id),
  education_level_id uuid not null references education_levels(id),
  subject_id uuid not null references subjects(id),
  semester text,
  source_school text,
  year int,
  is_national_exam boolean not null default false,
  access_scope jsonb not null default '{}'::jsonb,
  paper_path text not null,
  correction_path text
);

create table if not exists live_classes (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references profiles(id),
  subject_id uuid not null references subjects(id),
  education_level_id uuid not null references education_levels(id),
  title text not null,
  access_scope jsonb not null default '{}'::jsonb,
  zoom_link text not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null
);
