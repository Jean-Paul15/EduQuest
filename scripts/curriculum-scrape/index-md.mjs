// Regenere curriculum/index.md (sommaire humain) depuis le manifest.
import { writeRootText } from './writer.mjs';

const kb = (b) => (b ? `${(b / 1024).toFixed(0)} Ko` : '0');

function fileLine(f) {
  if (!f.relPath) return `      - [lien] ${f.sourceUrl}`;
  return `      - ${f.relPath}  (${kb(f.bytes)}${f.kind === 'file' ? '' : ', ' + f.kind})`;
}

export async function writeIndex(m) {
  const out = [
    '# Curriculum lycee — index',
    '',
    `Source : ${m.source}`,
    `Derniere aspiration : ${m.scrapedAt || '—'}`,
    '',
    '> Genere par `scripts/curriculum-scrape`. Ne pas editer a la main.',
    '',
  ];

  for (const [classe, cnode] of Object.entries(m.tree)) {
    out.push(`## ${classe}`, '');
    for (const [serie, snode] of Object.entries(cnode.series)) {
      out.push(`### ${serie}`, '');
      for (const [matiere, subnode] of Object.entries(snode.subjects)) {
        const chapters = Object.entries(subnode.chapters);
        out.push(`- **${matiere}** — ${chapters.length} chapitre(s)`);
        for (const [chapitre, ch] of chapters) {
          const files = ch.files || [];
          out.push(`  - ${chapitre} — ${files.length} ressource(s) · [source](${ch.url})`);
          for (const s of ch.sections || []) {
            if (/^(general|généralités?)$/i.test(s.name)) continue;
            out.push(`    - _${s.name}_${s.modules?.length ? ` (${s.modules.length} module)` : ''}`);
          }
          for (const f of files) out.push(fileLine(f));
        }
      }
      out.push('');
    }
  }

  const specials = Object.entries(m.specials || {});
  if (specials.length) {
    out.push('## Hors arborescence', '');
    for (const [name, node] of specials) {
      out.push(`- **${name}** (${node.kind}) — ${(node.files || []).length} fichier(s)`);
      for (const f of node.files || []) out.push(fileLine(f));
    }
    out.push('');
  }

  if (m.unresolved?.length) out.push('## Non resolu', '', ...m.unresolved.map((u) => `- ${u}`), '');
  await writeRootText('index.md', out.join('\n') + '\n');
}
