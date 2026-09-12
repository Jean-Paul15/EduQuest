// Parse une page cours Moodle -> sections (chapitres pedagogiques) + modules d'activite.
import * as cheerio from 'cheerio';
import { BASE } from './config.mjs';
import { request } from './http.mjs';

const MOD_RE = /\/mod\/(\w+)\/view\.php\?id=(\d+)/;
// Modules de contenu pedagogique uniquement (on ignore forum, chat, feedback...).
const CONTENT_MODS = new Set(['resource', 'folder', 'url', 'page', 'book', 'lesson', 'scorm', 'quiz']);

export async function fetchCourse(courseId, { cache = true } = {}) {
  const { body } = await request(`${BASE}/course/view.php?id=${courseId}`, { cache });
  const $ = cheerio.load(body);
  const title = $('.page-header-headings h1, h1.h2').first().text().trim() || `cours-${courseId}`;
  const summary = $('.course-description-item, .summarytext').first().text().trim();
  const bodyClass = $('body').attr('class') || '';

  // Format "activite unique" : le cours EST un seul module (souvent un dossier).
  if (/format-singleactivity/.test(bodyClass)) {
    const type = bodyClass.match(/cm-type-(\w+)/)?.[1] || 'resource';
    const cmid = Number(bodyClass.match(/cmid-(\d+)/)?.[1]) || null;
    return {
      id: courseId,
      title,
      summary,
      format: 'singleactivity',
      sections: [{ position: 0, name: title, modules: cmid ? [{ type, cmid, name: title }] : [] }],
    };
  }

  const sections = [];
  $('li.section, div.section[id^="section-"]').each((i, el) => {
    const node = $(el);
    const position = Number(node.attr('id')?.match(/section-(\d+)/)?.[1] ?? i);
    const name =
      node.find('h3.sectionname, .sectionname, span.hidden.sectionname').first().text().trim() ||
      `Section ${position}`;
    const modules = [];
    node.find('a[href*="/mod/"]').each((_, a) => {
      const m = ($(a).attr('href') || '').match(MOD_RE);
      if (!m || !CONTENT_MODS.has(m[1])) return;
      const label =
        $(a).find('.instancename').clone().children('.accesshide').remove().end().text().trim() ||
        $(a).text().trim();
      if (!modules.some((x) => x.cmid === Number(m[2])))
        modules.push({ type: m[1], cmid: Number(m[2]), name: label || `${m[1]}-${m[2]}` });
    });
    node.find('a[href*="pluginfile.php"]').each((_, a) => {
      modules.push({ type: 'inlinefile', url: $(a).attr('href'), name: $(a).text().trim() });
    });
    if (name !== `Section ${position}` || modules.length) sections.push({ position, name, modules });
  });

  return { id: courseId, title, summary, format: 'topics', sections };
}
