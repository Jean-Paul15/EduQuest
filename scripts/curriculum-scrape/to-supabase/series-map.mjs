// Mapping vers le modele REEL de la base : niveaux accentues, series A/C/D (Seconde: A/S).

// Cle arbre manifest -> education_levels.code (tel qu'en base).
export const LEVEL_CODE = { Seconde: 'Seconde', Premiere: 'Première', Terminale: 'Terminale' };

// "A4"/"C4" -> "A"/"C" ; "C & D" (Seconde) -> "S".
export function serieFromNode(classeKey, serieNodeName) {
  const level = LEVEL_CODE[classeKey];
  const rest = serieNodeName.replace(/^(seconde|premi[eè]re?|terminale?)\s*/i, '').trim();
  if (/c\s*&\s*d|c\s+et\s+d|c\s*\/\s*d/i.test(rest)) return { level, code: 'S' };
  const code = rest.replace(/\s+/g, '').replace(/4$/, '').toUpperCase() || 'GEN';
  return { level, code };
}

// Niveau devine depuis un nom de fichier d'epreuve (compos regionales, niveaux melanges).
export function levelFromFilename(name) {
  const n = name.toLowerCase().replace(/[_.-]+/g, ' ');
  if (/\btle|terminales?/.test(n)) return 'Terminale';
  if (/\b1\s?(ere|re|ère)|premi[eè]res?/.test(n)) return 'Première';
  if (/\b2\s?(nde|de)|secondes?/.test(n)) return 'Seconde';
  return null;
}

// Series ciblees -> codes REELS. Seconde: {A, S}. Autres: {A, C, D}.
export function seriesFromFilename(name, folderSerie, level) {
  const n = name.toLowerCase().replace(/[^a-z0-9]+/g, ' ');
  if (level === 'Seconde') {
    if (/\ba\s?4?\b/.test(n) || /\bl\b/.test(n)) return ['A'];
    if (folderSerie && /^a/i.test(folderSerie) && !/\bs\b|seconde\s?s/.test(n)) return ['A'];
    return ['S'];
  }
  const out = new Set();
  if (/\ba\s?4?\b/.test(n) || /\bl\b/.test(n)) out.add('A');
  if (/\bc\s?4?\b/.test(n) || /\bcd\b/.test(n)) out.add('C');
  if (/\bd\b/.test(n) || /\bcd\b/.test(n)) out.add('D');
  if (out.size) return [...out];
  const f = (folderSerie || '').toUpperCase().replace('4', '');
  if (['A', 'C', 'D'].includes(f)) return [f];
  return [];
}
