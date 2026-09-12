#!/usr/bin/env node
// CLI d'aspiration du curriculum lycee. Voir README.md.
import { BASE } from './config.mjs';
import { prime } from './http.mjs';
import { loadManifest, saveManifest } from './manifest.mjs';
import { scrapeClasses, scrapeSpecials } from './crawl.mjs';
import { writeIndex } from './index-md.mjs';
import { writeSeed } from './seed-sql.mjs';

const argv = new Set(process.argv.slice(2));
const opts = {
  discover: argv.has('--discover'),
  download: !argv.has('--discover') && !argv.has('--no-download'),
  seedOnly: argv.has('--seed'),
};

async function main() {
  const m = await loadManifest();

  if (opts.seedOnly) {
    await writeSeed(m);
    console.log('seed -> curriculum/seed/');
    return;
  }

  console.log(`Aspiration ${BASE} (discover=${opts.discover}, download=${opts.download})`);
  await prime(BASE);
  await scrapeClasses(m, opts);
  await scrapeSpecials(m, opts);
  await saveManifest(m);
  await writeIndex(m);
  if (!opts.discover) await writeSeed(m);

  const classes = Object.keys(m.tree).length;
  const specials = Object.keys(m.specials).length;
  console.log(`OK — ${classes} classe(s), ${specials} cours hors-arbre. manifest.json + index.md ecrits.`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
