// Enregistrements d'epreuves -> SQL migration 213 (exam_papers + exam_paper_series_targets).
// `paper_path` / `correction_path` sont des URL PUBLIQUES completes (convention `resources`,
// requis par l'ingestion RAG `ai-course-ingest`).
const BUCKET_URL =
  'https://qxmrrukeppikbygnramq.supabase.co/storage/v1/object/public/eduquest-content/';
const q = (s) => `'${String(s).replace(/'/g, "''")}'`;
const nn = (s) => (s == null ? 'null' : q(s));
const url = (key) => q(BUCKET_URL + key);

export function buildExamsSql(papers) {
  const rows = papers.map(
    (p) =>
      `(${q(p.level)},${q(p.subject)},${nn(p.semester)},${nn(p.source)},${p.year},${p.isNational},${url(p.storageKey)},${p.correction ? url(p.correction) : 'null'})`,
  );
  const targets = [];
  for (const p of papers) for (const s of p.series) targets.push(`(${url(p.storageKey)},${q(p.level)},${q(s)})`);

  return `-- 213: epreuves (BAC 1 national Premiere + compositions regionales Savanes) importees depuis ecole.gouv.tg
do $$
declare v_country uuid;
begin
  select id into v_country from countries where code = 'TG';

  insert into exam_papers (country_id, education_level_id, subject_id, semester, source_school,
                           year, is_national_exam, access_scope, paper_path, correction_path, published)
  select v_country, el.id, sb.id, v.semester, v.source, v.year::int, v.national, '{}'::jsonb, v.paper, v.correction, true
  from (values
    ${rows.join(',\n    ')}
  ) v(level_code, subj_code, semester, source, year, national, paper, correction)
  join education_levels el on el.country_id = v_country and el.code = v.level_code
  join subjects sb on sb.country_id = v_country and sb.code = v.subj_code
  where not exists (select 1 from exam_papers x where x.paper_path = v.paper);

  insert into exam_paper_series_targets (exam_paper_id, series_id)
  select ep.id, sr.id
  from (values
    ${targets.join(',\n    ')}
  ) v(paper, level_code, serie_code)
  join exam_papers ep on ep.paper_path = v.paper
  join education_levels el on el.country_id = v_country and el.code = v.level_code
  join series sr on sr.education_level_id = el.id and sr.code = v.serie_code
  where not exists (select 1 from exam_paper_series_targets t where t.exam_paper_id = ep.id and t.series_id = sr.id);
end $$;
`;
}
