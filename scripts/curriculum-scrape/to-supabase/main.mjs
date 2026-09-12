#!/usr/bin/env node
// Genere les migrations 210/211/212/213 + le plan d'upload depuis curriculum/manifest.json.
// Flags : --upload  (execute l'upload Storage des PDF depuis le plan)
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildFoundationSql } from './build-foundation.mjs';
import { buildPurgeSql } from './build-purge.mjs';
import { buildSql as buildCurriculum } from './build-curriculum.mjs';
import { collectExams } from './build-exams.mjs';
import { buildExamsSql } from './build-exams-sql.mjs';
import { uploadAll } from './upload-pdfs.mjs';

const ROOT = fileURLToPath(new URL('../../../curriculum/', import.meta.url));
const SEED = join(ROOT, 'seed');
const rd = (p) => readFile(join(ROOT, p), 'utf8').then(JSON.parse);

async function main() {
  await mkdir(SEED, { recursive: true });
  const manifest = await rd('manifest.json');

  if (process.argv.includes('--upload')) {
    const plan = JSON.parse(await readFile(join(SEED, 'upload-plan.json'), 'utf8'));
    console.log(`Upload ${plan.length} PDF -> eduquest-content ...`);
    const res = await uploadAll(plan);
    console.log(`Upload OK: ${res.uploaded}, echecs: ${res.failures.length}`);
    if (res.failures.length) await writeFile(join(SEED, 'upload-failures.json'), JSON.stringify(res.failures, null, 2));
    return;
  }

  await writeFile(join(SEED, '210_tg_foundation_realign.sql'), buildFoundationSql());
  await writeFile(join(SEED, '211_tg_purge_demo.sql'), buildPurgeSql());

  const cur = buildCurriculum(manifest);
  await writeFile(join(SEED, '212_tg_curriculum.sql'), cur.sql);
  console.log('212 curriculum:', cur.counts);
  if (cur.unresolved.length) console.log('  matieres NON resolues:', cur.unresolved);

  const { papers, unresolved } = collectExams(manifest);
  await writeFile(join(SEED, '213_tg_exam_papers.sql'), buildExamsSql(papers));
  const plan = [];
  for (const p of papers) {
    plan.push({ storageKey: p.storageKey, relPath: p.relPath });
    if (p.correction && p.correctionRelPath) plan.push({ storageKey: p.correction, relPath: p.correctionRelPath });
  }
  await writeFile(join(SEED, 'upload-plan.json'), JSON.stringify(plan, null, 2));
  console.log(`213 exam_papers: ${papers.length} epreuves, ${plan.length} fichiers a uploader`);
  await writeFile(join(SEED, 'exam-unresolved.json'), JSON.stringify(unresolved, null, 2));
  if (unresolved.length) console.log(`  epreuves NON resolues: ${unresolved.length} -> seed/exam-unresolved.json`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
