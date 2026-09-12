// Parcourt curriculum/manifest.json -> structures pretes pour le SQL de la migration 212.
import { resolveSubject } from './subject-map.mjs';
import { serieFromNode } from './series-map.mjs';

const stripPos = (s) => s.replace(/^\d+-/, '').trim();
// Cle de fusion : le site liste le meme chapitre 2x par serie (Title Case vs TOUT EN MAJ,
// ponctuation/espaces variables). On fusionne sur une forme normalisee.
const normKey = (t) =>
  t.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
const isAllCaps = (t) => /[A-Z]/.test(t) && t === t.toUpperCase();

export function collect(manifest) {
  const seriesSubjects = new Set(); // level|serie|subj
  const chapters = new Map(); // level|subj|normKey -> {title, pos}
  const targets = new Set(); // level|subj|normKey|serie
  const unresolved = new Set();
  const pos = new Map(); // level|subj -> counter

  for (const [classe, cnode] of Object.entries(manifest.tree)) {
    for (const [serieName, snode] of Object.entries(cnode.series)) {
      const { level, code: serie } = serieFromNode(classe, serieName);
      for (const [matiere, sub] of Object.entries(snode.subjects)) {
        const subj = resolveSubject(matiere);
        if (!subj) {
          unresolved.add(matiere);
          continue;
        }
        seriesSubjects.add(`${level}|${serie}|${subj}`);
        // Anglais Terminale : contenu curate deja publie en base -> series_subjects seulement.
        if (subj === 'ANGL' && level === 'Terminale') continue;
        for (const chapKey of Object.keys(sub.chapters)) {
          const title = stripPos(chapKey);
          const ck = `${level}|${subj}|${normKey(title)}`;
          const cur = chapters.get(ck);
          if (!cur) {
            const pk = `${level}|${subj}`;
            const n = (pos.get(pk) ?? 0) + 1;
            pos.set(pk, n);
            chapters.set(ck, { title, pos: n });
          } else if (isAllCaps(cur.title) && !isAllCaps(title)) {
            cur.title = title; // prefere une casse lisible
          }
          targets.add(`${ck}|${serie}`);
        }
      }
    }
  }
  return { seriesSubjects, chapters, targets, unresolved };
}
