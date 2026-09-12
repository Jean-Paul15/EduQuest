// Orchestration : categories -> cours -> modules -> fichiers, ecrits dans le manifest.
import { join } from 'node:path';
import { BASE, CLASSES, SPECIAL_COURSES } from './config.mjs';
import { request } from './http.mjs';
import { walkCourses } from './moodle-category.mjs';
import { fetchCourse } from './moodle-course.mjs';
import { resolveModule } from './moodle-resource.mjs';
import { chapterNode, knownSha, recordFile, specialNode } from './manifest.mjs';
import { chapterDir, safeName, safeRelPath } from './slugify.mjs';
import { fileExists, writeBinary, writeTextFile } from './writer.mjs';

const splitTrail = (trail) => ({
  matiere: safeName(trail[trail.length - 1] || 'Divers'),
  serie: safeName(trail.slice(0, -1).join(' - ') || 'Tronc commun'),
});

async function ingestResource(node, baseDir, res, { download }) {
  if (res.kind === 'link') return recordFile(node, { relPath: null, kind: 'link', sourceUrl: res.url });
  if (res.kind === 'html') {
    const rel = join(baseDir, safeName(res.filename)).replaceAll('\\', '/');
    if (download) await writeTextFile(rel, res.html || '');
    return recordFile(node, { relPath: rel, kind: 'html', bytes: (res.html || '').length });
  }
  const rel = join(baseDir, res.innerPath ? safeRelPath(res.innerPath) : safeName(res.filename))
    .replaceAll('\\', '/');
  const prev = knownSha(node, rel);
  let sha = prev;
  let bytes = node.files.find((f) => f.relPath === rel)?.bytes ?? null;
  let contentType = node.files.find((f) => f.relPath === rel)?.contentType ?? null;
  // --resume : deja aspire et present sur disque -> aucune requete.
  if (download && !(prev && (await fileExists(rel)))) {
    const dl = await request(res.url, { binary: true });
    contentType = dl.headers.get('content-type');
    const w = await writeBinary(rel, dl.body, prev);
    sha = w.sha256;
    bytes = w.bytes;
  }
  recordFile(node, { relPath: rel, kind: 'file', sourceUrl: res.url, sha256: sha, bytes, contentType });
}

async function ingestCourse(node, baseDir, courseId, opts) {
  const course = await fetchCourse(courseId);
  node.format = course.format;
  node.sections = course.sections.map((s) => ({
    position: s.position,
    name: s.name,
    modules: s.modules.map((m) => ({ type: m.type, name: m.name })),
  }));
  // Materialise le squelette de dossiers + metadonnees, meme sans fichier a aspirer.
  await writeTextFile(
    `${baseDir}/_chapitre.json`,
    JSON.stringify({ courseId, url: node.url, format: node.format, title: course.title, sections: node.sections }, null, 2),
  );
  for (const section of course.sections) {
    for (const mod of section.modules) {
      const resources = await resolveModule(mod).catch(() => []);
      for (const res of resources) await ingestResource(node, baseDir, res, opts);
    }
  }
}

export async function scrapeClasses(m, opts) {
  for (const cls of CLASSES) {
    const counters = new Map();
    for await (const { trail, course } of walkCourses(cls.categoryid)) {
      const { serie, matiere } = splitTrail(trail);
      const key = `${serie}/${matiere}`;
      const idx = (counters.get(key) ?? 0) + 1;
      counters.set(key, idx);
      const chapitre = chapterDir(idx, course.name);
      const node = chapterNode(m, {
        classe: cls.name, serie, matiere, chapitre,
        courseId: course.id, url: `${BASE}/course/view.php?id=${course.id}`,
      });
      if (opts.discover) continue;
      const baseDir = `${cls.name}/${serie}/${matiere}/${chapitre}`;
      await ingestCourse(node, baseDir, course.id, opts);
    }
  }
}

export async function scrapeSpecials(m, opts) {
  for (const sp of SPECIAL_COURSES) {
    const node = specialNode(m, { name: sp.name, courseId: sp.courseid, kind: sp.kind });
    if (opts.discover) continue;
    await ingestCourse(node, sp.name, sp.courseid, opts);
  }
}
