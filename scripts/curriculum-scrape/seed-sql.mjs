// Genere curriculum/seed/*.sql (artefacts de travail, PAS des migrations) depuis le manifest.
import { mkdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { SEED_DIR } from './config.mjs';

const LEVEL_LABEL = { Seconde: 'Seconde', Premiere: 'Premiere', Terminale: 'Terminale' };
const q = (s) => `'${String(s).replace(/'/g, "''")}'`;
const code = (label) =>
  label.normalize('NFD').replace(/[̀-ͯ]/g, '').toUpperCase().replace(/[^A-Z0-9]+/g, '_').slice(0, 24).replace(/_+$/, '');
const lvl = (classe) =>
  `(select el.id from education_levels el join countries c on c.id = el.country_id where c.code = 'TG' and el.label = ${q(LEVEL_LABEL[classe] || classe)})`;
const subj = (label) =>
  `(select s.id from subjects s join countries c on c.id = s.country_id where c.code = 'TG' and s.code = ${q(code(label))})`;

function collect(m) {
  const subjects = new Set();
  const chapters = [];
  const resources = [];
  for (const [classe, cn] of Object.entries(m.tree))
    for (const [serie, sn] of Object.entries(cn.series))
      for (const [matiere, sub] of Object.entries(sn.subjects)) {
        subjects.add(matiere);
        Object.entries(sub.chapters).forEach(([chapitre, ch], i) => {
          chapters.push({ classe, matiere, title: chapitre.replace(/^\d+-/, ''), position: i + 1 });
          for (const f of ch.files || [])
            if (f.kind === 'file')
              resources.push({ classe, matiere, chapTitle: chapitre.replace(/^\d+-/, ''), url: f.sourceUrl, title: f.relPath.split('/').pop() });
        });
      }
  return { subjects: [...subjects], chapters, resources };
}

const subjectsSql = (list) =>
  'begin;\n' +
  list
    .map(
      (label) =>
        `insert into subjects (country_id, code, label)\nselect c.id, ${q(code(label))}, ${q(label)} from countries c where c.code = 'TG'\non conflict (country_id, code) do update set label = excluded.label;`,
    )
    .join('\n') +
  '\ncommit;\n';

const chaptersSql = (list) =>
  'begin;\n' +
  list
    .map(
      (c) =>
        `insert into chapters (subject_id, education_level_id, title, position)\nselect ${subj(c.matiere)}, ${lvl(c.classe)}, ${q(c.title)}, ${c.position}\nwhere not exists (select 1 from chapters ch where ch.subject_id = ${subj(c.matiere)} and ch.education_level_id = ${lvl(c.classe)} and ch.title = ${q(c.title)});`,
    )
    .join('\n') +
  '\ncommit;\n';

const resourcesSql = (list) =>
  'begin;\n' +
  list
    .map(
      (r) =>
        `insert into resources (chapter_id, type, title, external_url, is_downloadable, published, version)\nselect ch.id, 'pdf', ${q(r.title)}, ${q(r.url)}, true, false, '1.0.0'\nfrom chapters ch where ch.subject_id = ${subj(r.matiere)} and ch.education_level_id = ${lvl(r.classe)} and ch.title = ${q(r.chapTitle)}\nand not exists (select 1 from resources x where x.chapter_id = ch.id and x.external_url = ${q(r.url)});`,
    )
    .join('\n') +
  '\ncommit;\n';

function examPapersSql(m) {
  const rows = [];
  for (const node of Object.values(m.specials || {}))
    for (const f of node.files || []) {
      if (f.kind !== 'file') continue;
      const p = (f.relPath || '').split('/');
      const year = Number(p.find((s) => /^\d{4}$/.test(s))) || null;
      rows.push(
        `-- ${f.relPath}\ninsert into exam_papers (country_id, education_level_id, subject_id, year, is_national_exam, semester, paper_path, access_scope, published)\nselect c.id, null, null, ${year ?? 'null'}, ${node.kind === 'exam'}, ${node.kind === 'compo' ? "'regionale'" : 'null'}, ${q(f.sourceUrl)}, '{}'::jsonb, false\nfrom countries c where c.code = 'TG'\nand not exists (select 1 from exam_papers x where x.paper_path = ${q(f.sourceUrl)});`,
      );
    }
  return rows.length ? 'begin;\n' + rows.join('\n') + '\ncommit;\n' : '-- aucun sujet trouve\n';
}

const report = (d) =>
  `# Rapport de resolution FK\n\nAvant promotion vers backend/schema/, remplacer les codes matiere auto par les codes canoniques (ANGL, SVT...).\n\n## Matieres detectees (subjects.code auto)\n\n${d.subjects.map((s) => `- ${s} -> \`${code(s)}\``).join('\n')}\n\n## Volumes\n\n- chapitres : ${d.chapters.length}\n- ressources fichier : ${d.resources.length}\n`;

export async function writeSeed(m) {
  await mkdir(SEED_DIR, { recursive: true });
  const d = collect(m);
  await Promise.all([
    writeFile(join(SEED_DIR, '00_subjects.sql'), subjectsSql(d.subjects)),
    writeFile(join(SEED_DIR, '10_chapters.sql'), chaptersSql(d.chapters)),
    writeFile(join(SEED_DIR, '20_resources.sql'), resourcesSql(d.resources)),
    writeFile(join(SEED_DIR, '30_exam_papers.sql'), examPapersSql(m)),
    writeFile(join(SEED_DIR, 'RESOLUTION_REPORT.md'), report(d)),
  ]);
}
