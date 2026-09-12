# to-supabase

Genere les migrations d'import curriculum depuis `curriculum/manifest.json` vers Supabase,
et uploade les PDF d'annales dans le bucket `eduquest-content`.

## Usage

```bash
node to-supabase/main.mjs            # (re)genere curriculum/seed/210..213 + upload-plan.json
node to-supabase/main.mjs --upload   # uploade les PDF (SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY requis)
```

L'upload exige un **JWT legacy** (`eyJ…`) : le Storage de ce projet rejette la cle
`sb_secret_…` (« Invalid Compact JWS »). Fournir la cle `service_role` du dashboard.

## Migrations produites (appliquees via MCP `apply_migration`, miroir dans `backend/schema/`)

| # | Role |
|---|---|
| 210 | Realignement socle : `EDHC`->`ECM`, `HIST`="Histoire-Geographie" (combine), drop `GEO`, series Seconde `A`+`S` |
| 211 | Purge du contenu de demo (`example.com`), preserve Anglais Terminale curate |
| 212 | Import programme : `series_subjects` (70), `chapters` (173, dedup casse-insensible), `chapter_series_targets` (338). Anglais Tle exclu (contenu reel deja en base) |
| 213 | Import epreuves : `exam_papers` (219, `access_scope='{}'`), `exam_paper_series_targets` (309). BAC 1 = **Premiere** ; compos Savanes 2023 |

## Conventions de mapping

- Niveaux : `Seconde` / `Première` / `Terminale` (accentues, tels qu'en base).
- Series : `A4`/`C4` du site -> `A`/`C` ; Seconde « C & D » -> `S`.
- Matieres : voir `subject-map.mjs`. Physique/Chimie et Histoire/Geo restent combines
  (`PC`, `HIST`) : la source ne les separe jamais.
- 1 fichier compo non resolu (`Maths- A4-2023.pdf`, sans marqueur de niveau) -> `seed/exam-unresolved.json`.
