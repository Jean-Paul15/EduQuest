// Parcours des categories Moodle : classe -> serie(s) -> matiere -> cours (= chapitre).
import * as cheerio from 'cheerio';
import { BASE, PERPAGE } from './config.mjs';
import { request } from './http.mjs';

const categoryUrl = (id) => `${BASE}/course/index.php?categoryid=${id}&perpage=${PERPAGE}`;

// Retourne { id, name, subcategories:[{id,name}], courses:[{id,name}] }.
export async function fetchCategory(id, { cache = true } = {}) {
  const { body } = await request(categoryUrl(id), { cache });
  const $ = cheerio.load(body);
  const name =
    $('.page-header-headings h1').first().text().trim() ||
    $('h1').first().text().trim() ||
    `categorie-${id}`;

  const subcategories = [];
  $('div.category[data-categoryid]').each((_, el) => {
    const subId = Number($(el).attr('data-categoryid'));
    const link = $(el).find('h3.categoryname a, .categoryname a').first();
    const label = link.text().trim();
    if (subId && subId !== id && label) subcategories.push({ id: subId, name: label });
  });

  const courses = [];
  $('a.aalink[href*="course/view.php?id="], .coursename a[href*="course/view.php?id="]').each(
    (_, el) => {
      const href = $(el).attr('href') || '';
      const cid = Number(href.match(/id=(\d+)/)?.[1]);
      const label = $(el).text().trim();
      if (cid && label && !courses.some((c) => c.id === cid)) courses.push({ id: cid, name: label });
    },
  );

  return { id, name, subcategories: dedupe(subcategories), courses };
}

function dedupe(list) {
  const seen = new Set();
  return list.filter((x) => (seen.has(x.id) ? false : seen.add(x.id)));
}

// Descend recursivement et yield { trail:[serie..., matiere], course:{id,name} }.
// La categorie racine (la classe) n'entre pas dans `trail` : le caller la connait deja.
const visited = new Set();
export async function* walkCourses(categoryId, trail = [], isRoot = true) {
  if (isRoot) visited.clear();
  if (visited.has(categoryId)) return;
  visited.add(categoryId);
  const cat = await fetchCategory(categoryId);
  const here = isRoot ? [] : [...trail, cat.name];
  for (const course of cat.courses) yield { trail: here, course };
  for (const sub of cat.subcategories) yield* walkCourses(sub.id, here, false);
}
