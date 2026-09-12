// Manifest -> SQL migration 212 (series_subjects, chapters, chapter_series_targets).
import { collect } from './curriculum-collect.mjs';

const q = (s) => `'${String(s).replace(/'/g, "''")}'`;
const valuesBlock = (rows) => rows.map((r) => `(${r.map(q).join(',')})`).join(',\n    ');

export { collect };

export function buildSql(manifest) {
  const c = collect(manifest);
  const ss = [...c.seriesSubjects].map((k) => k.split('|'));
  const ch = [...c.chapters].map(([k, v]) => {
    const [level, subj] = k.split('|');
    return [level, subj, v.title, String(v.pos)];
  });
  const tg = [...c.targets].map((k) => {
    const [level, subj, norm, serie] = k.split('|');
    return [level, subj, c.chapters.get(`${level}|${subj}|${norm}`).title, serie];
  });

  const sql = `-- 212: curriculum lycee Togo importe depuis ecole.gouv.tg (Moodle MEPSTA)
do $$
declare v_country uuid;
begin
  select id into v_country from countries where code = 'TG';

  insert into series_subjects (series_id, subject_id)
  select sr.id, sb.id
  from (values
    ${valuesBlock(ss)}
  ) v(level_code, serie_code, subj_code)
  join education_levels el on el.country_id = v_country and el.code = v.level_code
  join series sr on sr.education_level_id = el.id and sr.code = v.serie_code
  join subjects sb on sb.country_id = v_country and sb.code = v.subj_code
  where not exists (select 1 from series_subjects x where x.series_id = sr.id and x.subject_id = sb.id);

  insert into chapters (subject_id, education_level_id, title, position, published)
  select sb.id, el.id, v.title, v.pos::int, true
  from (values
    ${valuesBlock(ch)}
  ) v(level_code, subj_code, title, pos)
  join education_levels el on el.country_id = v_country and el.code = v.level_code
  join subjects sb on sb.country_id = v_country and sb.code = v.subj_code
  where not exists (select 1 from chapters x
    where x.subject_id = sb.id and x.education_level_id = el.id and x.title = v.title);

  insert into chapter_series_targets (chapter_id, series_id)
  select c.id, sr.id
  from (values
    ${valuesBlock(tg)}
  ) v(level_code, subj_code, title, serie_code)
  join education_levels el on el.country_id = v_country and el.code = v.level_code
  join subjects sb on sb.country_id = v_country and sb.code = v.subj_code
  join chapters c on c.subject_id = sb.id and c.education_level_id = el.id and c.title = v.title
  join series sr on sr.education_level_id = el.id and sr.code = v.serie_code
  where not exists (select 1 from chapter_series_targets t where t.chapter_id = c.id and t.series_id = sr.id);
end $$;
`;
  return { sql, unresolved: [...c.unresolved], counts: { seriesSubjects: ss.length, chapters: ch.length, targets: tg.length } };
}
