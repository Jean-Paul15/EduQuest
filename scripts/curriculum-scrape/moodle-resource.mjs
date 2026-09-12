// Resout un module d'activite en ressources concretes (fichier / lien / html).
import * as cheerio from 'cheerio';
import { BASE } from './config.mjs';
import { request } from './http.mjs';

const abs = (href) => (href?.startsWith('http') ? href : `${BASE}/${String(href).replace(/^\//, '')}`);

function folderInnerPath(pluginUrl) {
  const raw = pluginUrl.match(/mod_folder\/content\/\d+\/(.+?)(\?|$)/)?.[1];
  return raw ? decodeURIComponent(raw) : null;
}

// -> [{ kind:'file'|'link'|'html', url?, innerPath?, filename?, html? }]
export async function resolveModule(mod) {
  if (mod.type === 'inlinefile' && mod.url) return [fileFrom(abs(mod.url))];
  if (!mod.cmid) return [];
  const viewUrl = `${BASE}/mod/${mod.type}/view.php?id=${mod.cmid}`;

  if (mod.type === 'folder') {
    const { body } = await request(viewUrl, { cache: true });
    const $ = cheerio.load(body);
    const out = [];
    $('a[href*="pluginfile.php"][href*="mod_folder/content"]').each((_, a) => {
      const url = abs($(a).attr('href'));
      if (!out.some((r) => r.url === url)) out.push(fileFrom(url));
    });
    return out;
  }

  if (mod.type === 'resource') {
    const res = await request(viewUrl, { cache: false });
    if (/pluginfile\.php/.test(res.url)) return [fileFrom(res.url)];
    const $ = cheerio.load(res.body);
    const links = [];
    $('.resourceworkaround a, .resourcecontent a, object[data*="pluginfile"]').each((_, el) => {
      const href = $(el).attr('href') || $(el).attr('data');
      if (href) links.push(fileFrom(abs(href)));
    });
    return links.length ? links : [{ kind: 'link', url: res.url }];
  }

  if (mod.type === 'url') {
    const { body } = await request(viewUrl, { cache: true });
    const $ = cheerio.load(body);
    const href = $('.urlworkaround a, .box.generalbox a[href^="http"]').first().attr('href');
    return [{ kind: 'link', url: href || viewUrl }];
  }

  if (mod.type === 'page' || mod.type === 'book') {
    const { body } = await request(viewUrl, { cache: true });
    const $ = cheerio.load(body);
    const html = $('#region-main .box, [role="main"]').first().html() || body;
    const extra = [];
    $('#region-main a[href*="pluginfile.php"]').each((_, a) => extra.push(fileFrom(abs($(a).attr('href')))));
    return [{ kind: 'html', filename: `${mod.type}.html`, html }, ...extra];
  }

  return [{ kind: 'link', url: viewUrl }];
}

function fileFrom(url) {
  const clean = url.split('?')[0];
  const filename = decodeURIComponent(clean.slice(clean.lastIndexOf('/') + 1)) || 'fichier';
  return { kind: 'file', url, filename, innerPath: folderInnerPath(url) };
}
