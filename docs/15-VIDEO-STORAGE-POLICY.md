# Politique Vidéos (coût stockage)

## Règle principale
- Les vidéos EduQuest doivent être publiées en priorité sur YouTube.
- L’app affiche ensuite le lien YouTube (`resources.type = 'youtube'`).

## Pourquoi
- Réduire les coûts de stockage et de bande passante.
- Garder une diffusion stable sur réseaux mobiles faibles.

## Règles DB
- `type = 'youtube'`:
  - `external_url` obligatoire,
  - `storage_path` interdit.
- `type = 'video'`:
  - `external_url` ou `storage_path` obligatoire.

## Cas de partage inter-classes
- Utiliser `access_scope` vide ou multi-niveaux pour partager une vidéo.
- Exemple: Histoire commune Terminale C/D/A -> une seule ressource.

## Fichiers liés
- Migration: `backend/migrations/0007_video_storage_policy.sql`
- Schéma clean: `backend/schema/02_content.sql`

