// Manifest : source de verite machine + etat de reprise (--resume).
import { readRootJson, writeRootJson } from './writer.mjs';
import { BASE } from './config.mjs';

const NAME = 'manifest.json';

export async function loadManifest() {
  return readRootJson(NAME, { scrapedAt: null, source: BASE, tree: {}, specials: {}, unresolved: [] });
}

export async function saveManifest(m) {
  m.scrapedAt = new Date().toISOString();
  await writeRootJson(NAME, m);
}

// Cree/retourne le noeud chapitre pour un chemin classe/serie/matiere/chapitre.
export function chapterNode(m, { classe, serie, matiere, chapitre, courseId, url }) {
  const t = (m.tree[classe] ??= { series: {} });
  const s = (t.series[serie] ??= { subjects: {} });
  const sub = (s.subjects[matiere] ??= { chapters: {} });
  const ch = (sub.chapters[chapitre] ??= { courseId, url, format: null, sections: [], files: [] });
  ch.courseId = courseId;
  ch.url = url;
  return ch;
}

export function specialNode(m, { name, courseId, kind }) {
  const n = (m.specials[name] ??= { courseId, kind, files: [] });
  n.url = `${BASE}/course/view.php?id=${courseId}`;
  return n;
}

// Retrouve l'empreinte connue d'un fichier deja aspire (pour sauter le retelechargement).
export function knownSha(node, relPath) {
  return node.files.find((f) => f.relPath === relPath)?.sha256;
}

export function recordFile(node, entry) {
  const i = node.files.findIndex((f) => f.relPath === entry.relPath);
  if (i >= 0) node.files[i] = { ...node.files[i], ...entry };
  else node.files.push(entry);
}
