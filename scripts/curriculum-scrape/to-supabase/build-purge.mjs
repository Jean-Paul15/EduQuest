// SQL migration 211 : purge du contenu de demo (placeholder example.com / w3.org).
// PRESERVE : chapitres Anglais Terminale adosses a des PDF storage reels (contenu curate).
// Destructif et assume (feu vert utilisateur : le programme scrappe est la source de verite).
// FK chapters<-quizzes/resources sont NO ACTION -> on supprime les enfants d'abord.

export function buildPurgeSql() {
  return `-- 211: purge du contenu curriculum de demo (garde Anglais Terminale curate)
do $$
declare v_angl uuid; v_tle uuid;
begin
  select s.id into v_angl from subjects s join countries c on c.id = s.country_id
    where c.code = 'TG' and s.code = 'ANGL';
  select id into v_tle from education_levels where code = 'Terminale';

  create temporary table _demo_ch on commit drop as
  select c.id from chapters c
  where not (
    c.subject_id = v_angl and c.education_level_id = v_tle
    and exists (select 1 from resources r where r.chapter_id = c.id and r.storage_path is not null)
  );

  delete from quiz_questions where quiz_id in (select id from quizzes where chapter_id in (select id from _demo_ch));
  delete from quizzes where chapter_id in (select id from _demo_ch);
  delete from resources where chapter_id in (select id from _demo_ch);
  delete from learning_progress where chapter_id in (select id from _demo_ch);
  delete from chapters where id in (select id from _demo_ch);

  delete from exam_papers;          -- 16 placeholders (example.com / w3.org, published=false)
  delete from series_subjects;      -- table programme entierement redefinie par la migration 212
end $$;
`;
}
