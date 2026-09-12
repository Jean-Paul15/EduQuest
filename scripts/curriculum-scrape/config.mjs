// Configuration centrale de l'aspiration curriculum.
import { fileURLToPath } from 'node:url';

export const BASE = 'https://ecole.gouv.tg/lycee';

// Classes du lycee -> categorie racine Moodle.
export const CLASSES = [
  { name: 'Seconde', categoryid: 1 },
  { name: 'Premiere', categoryid: 5 },
  { name: 'Terminale', categoryid: 9 },
];

// Cours "single activity" hors arborescence classe/serie/matiere.
export const SPECIAL_COURSES = [
  { name: 'Sujets-examen', courseid: 2, kind: 'exam' },
  { name: 'Composition-regionale', courseid: 3, kind: 'compo' },
];

const root = (p) => fileURLToPath(new URL(p, import.meta.url));

export const OUT_ROOT = root('../../curriculum/');
export const LYCEE_DIR = root('../../curriculum/lycee/');
export const RAW_DIR = root('../../curriculum/_raw/');
export const SEED_DIR = root('../../curriculum/seed/');
export const MANIFEST = root('../../curriculum/manifest.json');
export const INDEX_MD = root('../../curriculum/index.md');

// Politesse reseau : infra .gouv.tg fragile, on reste lent et sequentiel.
export const REQUEST_DELAY_MS = 1500;
export const MAX_RETRIES = 4;
export const TIMEOUT_MS = 30000;
export const PERPAGE = 200;
export const USER_AGENT =
  'RuachEdu-Curriculum-Bot/1.0 (educational content mirror; source=ecole.gouv.tg)';
