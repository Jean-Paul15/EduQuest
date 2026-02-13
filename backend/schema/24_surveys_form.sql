create table if not exists survey_questions (
  id uuid primary key default gen_random_uuid(),
  survey_id uuid not null references surveys(id) on delete cascade,
  prompt text not null,
  question_type text not null check (question_type in ('text','mcq')),
  options jsonb not null default '[]'::jsonb,
  required boolean not null default true,
  position int not null default 0
);

create table if not exists survey_answers (
  id uuid primary key default gen_random_uuid(),
  survey_id uuid not null references surveys(id) on delete cascade,
  question_id uuid not null references survey_questions(id) on delete cascade,
  profile_id uuid not null references profiles(id),
  answer_text text,
  answer_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique(question_id, profile_id)
);

alter table survey_questions enable row level security;
alter table survey_answers enable row level security;
drop policy if exists survey_questions_read_scope on survey_questions;
create policy survey_questions_read_scope on survey_questions for select
using (exists(select 1 from surveys s where s.id = survey_id and can_match_profile_scope(s.target_scope)));
drop policy if exists survey_answers_self_all on survey_answers;
create policy survey_answers_self_all on survey_answers for all
using (profile_id = auth.uid() or get_user_role(auth.uid()) = 'admin')
with check (profile_id = auth.uid() or get_user_role(auth.uid()) = 'admin');

create or replace function submit_survey_answer(p_question_id uuid, p_answer_text text default null, p_answer_json jsonb default '{}'::jsonb)
returns jsonb language plpgsql security definer as $$
declare v_uid uuid := auth.uid(); v_sid uuid;
begin
  if v_uid is null then return jsonb_build_object('success',false,'message','Utilisateur non connecté.'); end if;
  select survey_id into v_sid from survey_questions where id = p_question_id;
  if v_sid is null then return jsonb_build_object('success',false,'message','Question introuvable.'); end if;
  if not exists(select 1 from surveys s where s.id=v_sid and can_match_profile_scope(s.target_scope, v_uid)) then
    return jsonb_build_object('success',false,'message','Enquête non accessible.');
  end if;
  insert into survey_answers(survey_id, question_id, profile_id, answer_text, answer_json)
  values(v_sid, p_question_id, v_uid, p_answer_text, coalesce(p_answer_json,'{}'::jsonb))
  on conflict (question_id, profile_id) do update set answer_text=excluded.answer_text, answer_json=excluded.answer_json, created_at=now();
  return jsonb_build_object('success',true,'message','Réponse enregistrée.');
end; $$;

grant execute on function submit_survey_answer(uuid, text, jsonb) to authenticated;
