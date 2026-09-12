// Resolution des libelles/fichiers ecole.gouv.tg vers les codes matiere REELS de la base.
// Post-migration 210 : EDHC -> ECM ; HIST reetiquete "Histoire-Geographie" (combine).
// La source ne separe jamais Physique/Chimie ni Histoire/Geographie -> PC et HIST combines.

export const KNOWN_CODES = ['ANGL', 'ALL', 'ESP', 'FR', 'ECM', 'PHILO', 'MATH', 'SVT', 'HIST', 'PC'];

const norm = (s) =>
  String(s || '')
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/\bremplacement\b|\bcorrige?\b|\bbis\b|\(\d+\)/g, ' ')
    .replace(/\b(tle|tles|terminale?s?|1ere|1re|2nde|2de|secondes?|premieres?)\b/g, ' ')
    .replace(/\b(a4|c4|d|a|c|cd|l)\b/g, ' ')
    .replace(/[^a-z]+/g, ' ')
    .trim();

const RULES = [
  [/svt|sciences? de la vie/, 'SVT'],
  [/\bhg\b|hist|geo/, 'HIST'], // combine : histoire-geographie (HG = abreviation frequente)
  [/pct|physique|phisique|chimie|sciences? physiques?|\bpc\b|\bsp\b/, 'PC'],
  [/math/, 'MATH'],
  [/anglais|english/, 'ANGL'],
  [/allemand|deutsch/, 'ALL'],
  [/espagnol|spanish/, 'ESP'],
  [/philo/, 'PHILO'],
  [/ecm|education civique|instruction civique/, 'ECM'],
  [/francais|\bfr\b|lettres/, 'FR'],
];

export function resolveSubject(raw) {
  const n = norm(raw);
  for (const [re, code] of RULES) if (re.test(n)) return code;
  return null;
}
