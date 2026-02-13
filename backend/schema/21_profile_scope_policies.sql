create or replace function can_match_profile_scope(target_scope jsonb, uid uuid default auth.uid())
returns boolean language plpgsql stable as $$
declare l_code text; s_code text; lv text[]; sv text[];
begin
  if uid is null or target_scope is null or target_scope='{}'::jsonb then return true; end if;
  select el.code, sr.code into l_code, s_code
  from profiles p
  left join education_levels el on el.id = p.education_level_id
  left join series sr on sr.id = p.series_id
  where p.id = uid;
  lv := coalesce((select array_agg(v) from jsonb_array_elements_text(coalesce(target_scope->'levels','[]'::jsonb)) v), '{}'::text[]);
  sv := coalesce((select array_agg(v) from jsonb_array_elements_text(coalesce(target_scope->'series','[]'::jsonb)) v), '{}'::text[]);
  if array_length(lv,1) is not null and (l_code is null or not (l_code = any(lv))) then return false; end if;
  if array_length(sv,1) is not null and (s_code is null or not (s_code = any(sv))) then return false; end if;
  return true;
end; $$;

alter table surveys enable row level security;
drop policy if exists resources_access_select on resources;
drop policy if exists quizzes_access_select on quizzes;
drop policy if exists exam_papers_access_select on exam_papers;
drop policy if exists live_classes_access_select on live_classes;
drop policy if exists contests_access_select on contests;
drop policy if exists events_access_select on events;
drop policy if exists surveys_access_select on surveys;

create policy resources_access_select on resources for select
using (published = true and has_scope_access(access_scope) and can_match_profile_scope(access_scope));
create policy quizzes_access_select on quizzes for select
using (published = true and has_scope_access(access_scope) and can_match_profile_scope(access_scope));
create policy exam_papers_access_select on exam_papers for select
using (has_scope_access(access_scope) and can_match_profile_scope(access_scope));
create policy live_classes_access_select on live_classes for select
using (has_scope_access(access_scope) and can_match_profile_scope(access_scope));
create policy contests_access_select on contests for select
using (has_scope_access(access_scope) and can_match_profile_scope(eligibility_scope));
create policy events_access_select on events for select
using (has_scope_access(access_scope) and can_match_profile_scope(access_scope));
create policy surveys_access_select on surveys for select
using (can_match_profile_scope(target_scope));
