// Manifest.specials -> enregistrements d'epreuves normalises (papier + corrige apparie).
import { resolveSubject } from './subject-map.mjs';
import { levelFromFilename, seriesFromFilename } from './series-map.mjs';

const ascii = (s) =>
  s.normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/[^A-Za-z0-9._-]+/g, '_').replace(/_+/g, '_');
const yearOf = (parts) => Number(parts.find((p) => /^\d{4}$/.test(p))) || null;
const isCorr = (name) => /corrig/i.test(name);
// Fichiers compo sans marqueur de niveau dans le nom : niveau confirme par le contenu du PDF.
const LEVEL_OVERRIDES = { 'Maths- A4-2023.pdf': 'Seconde' };

function parseFile(kind, relPath) {
  const parts = relPath.split('/');
  const file = parts[parts.length - 1];
  const base = file.replace(/\.pdf$/i, '');
  const year = yearOf(parts);
  const subject = resolveSubject(base);
  if (kind === 'exam') {
    const serieFolder = parts[parts.length - 2];
    return {
      subject, year, level: 'Première', isNational: true, semester: null, source: null,
      series: seriesFromFilename(base, serieFolder, 'Première'),
      isCorrection: isCorr(base),
      storageKey: `exams/bac1/${year}/${ascii(serieFolder)}/${ascii(file)}`,
    };
  }
  // compo : Composition-regionale / <year> / <region> / <semester> / <serieFolder> / <file>
  const region = parts[2] || 'Region';
  const semester = parts[3] || 'Semestre';
  const serieFolder = parts[parts.length - 2];
  const level = LEVEL_OVERRIDES[file] || levelFromFilename(base);
  return {
    subject, year, level, isNational: false,
    semester, source: region,
    series: seriesFromFilename(base, serieFolder, level),
    isCorrection: isCorr(base),
    storageKey: `exams/compos/${ascii(region)}-${year}-${ascii(semester)}/${ascii(parts[parts.length - 2])}/${ascii(file)}`,
  };
}

// -> { papers:[...], unresolved:[{relPath, why}] }
export function collectExams(manifest) {
  const rows = [];
  const unresolved = [];
  const seenSha = new Map(); // sha -> row (le meme fichier est parfois range sous A4/C4/D)
  for (const node of Object.values(manifest.specials || {})) {
    for (const f of node.files || []) {
      if (f.kind !== 'file' || !/\.pdf$/i.test(f.relPath)) continue;
      const r = parseFile(node.kind, f.relPath);
      r.relPath = f.relPath;
      r.sha = f.sha256;
      if (!r.subject || !r.level || r.series.length === 0 || !r.year) {
        unresolved.push({ relPath: f.relPath, why: `subject=${r.subject} level=${r.level} series=${r.series} year=${r.year}` });
        continue;
      }
      if (r.sha && seenSha.has(r.sha)) {
        const keep = seenSha.get(r.sha);
        keep.series = [...new Set([...keep.series, ...r.series])];
        continue;
      }
      if (r.sha) seenSha.set(r.sha, r);
      rows.push(r);
    }
  }
  return { papers: pairCorrections(rows), unresolved };
}

function pairCorrections(rows) {
  const key = (r) => [r.level, r.subject, r.series.join('+'), r.year, r.semester, r.source].join('|');
  const groups = new Map();
  for (const r of rows) {
    if (!groups.has(key(r))) groups.set(key(r), []);
    groups.get(key(r)).push(r);
  }
  const papers = [];
  for (const g of groups.values()) {
    const subj = g.filter((r) => !r.isCorrection);
    const corr = g.filter((r) => r.isCorrection);
    subj.forEach((p, i) =>
      papers.push({
        ...p,
        correction: corr[i]?.storageKey ?? null,
        correctionRelPath: corr[i]?.relPath ?? null,
      }),
    );
    corr.slice(subj.length).forEach((c) => papers.push({ ...c, correction: null, correctionRelPath: null }));
  }
  return papers;
}
