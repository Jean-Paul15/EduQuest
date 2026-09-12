# curriculum-scrape

Aspiration structuree du curriculum **lycee** depuis `ecole.gouv.tg` (instance Moodle
du MEPSTA) vers le dossier `curriculum/` a la racine du repo.

## Modele

```
Classe (Seconde / Premiere / Terminale)   = categorie racine Moodle
  Serie / filiere (A4, C, D, G...)         = sous-categorie
    Matiere                                = sous-categorie feuille
      Chapitre                             = "cours" Moodle (course/view.php?id=)
        Section                            = topic Moodle
          Ressource                        = module (resource / folder / url / page)
```

Deux cours hors arborescence, au format *single activity* :
`Sujets-examen` (`course id=2`) et `Composition-regionale` (`course id=3`).

## Usage

```bash
cd scripts/curriculum-scrape
npm install                 # cheerio

node main.mjs --discover     # structure seule (categories + chapitres), aucun telechargement
node main.mjs --no-download  # + sections/modules, sans ecrire les binaires
node main.mjs                # aspiration complete (PDF, HTML, dossiers)
node main.mjs --seed         # (re)genere curriculum/seed/*.sql depuis le manifest
```

Relancer `node main.mjs` est **idempotent** : un fichier dont le SHA-256 n'a pas
change n'est pas rewrite (voir `manifest.json`).

## Politesse reseau

Infra `.gouv.tg` fragile : 1 requete a la fois, delai 1,5 s, timeout 30 s, 4
reessais en backoff exponentiel. Le HTML brut est mis en cache dans
`curriculum/_raw/` pour reparser hors ligne sans re-solliciter le serveur.
User-Agent : `RuachEdu-Curriculum-Bot/1.0`.

## Sorties

| Fichier | Role | Versionne ? |
|---|---|---|
| `curriculum/manifest.json` | arbre + ids Moodle + URLs source + SHA-256 + etat de reprise | oui |
| `curriculum/index.md` | sommaire lisible (regenere) | non (`.gitignore` : `*.md`) |
| `curriculum/lycee/**` | fichiers miroir | binaires ignores par `.gitignore` |
| `curriculum/seed/*.sql` | upserts Supabase (artefacts de travail) | non (`.gitignore` : `*.sql`) |
| `curriculum/seed/RESOLUTION_REPORT.md` | matieres -> codes a mapper avant promotion | non |

## Promotion vers la base

`curriculum/seed/*.sql` sont des **brouillons**. Avant de les promouvoir dans
`backend/schema/` (+ miroir `backend/schema_compact/` + ordre dans
`docs/10-DB-EXECUTION-FLOW.md`) : remplacer les `subjects.code` auto par les codes
canoniques (`ANGL`, `SVT`, ...), verifier les `education_levels.label` reels, et
tester sur une branche Supabase jetable. `resources.published` / `exam_papers.published`
sont a `false` : rien n'est expose sans revue.

## Note de conformite

Le contenu provient du MEPSTA. Usage interne de reference / production de contenu
RuachEdu. Verifier les droits de rediffusion avant toute exposition publique.
