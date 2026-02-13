# Architecture EduQuest

## Stack
- Front: Flutter (web, android, ios).
- Backend: Supabase (Postgres, Auth, Storage, Realtime, Edge Functions).
- Site externe: vente tickets + presentation produit + campagne marketing.

## Principe
- Une seule base multi-pays.
- Configuration par metadonnees (pays, classe, serie, examen, campagne).
- Systeme d'acces compose de regles: ticket + partenariat + promo + role.

## Modules Flutter
- `features/auth`
- `features/feed`
- `features/content`
- `features/quiz`
- `features/exams`
- `features/live_classes`
- `features/contests`
- `features/events`
- `features/marketplace`
- `features/orientation`
- `features/tickets`
- `shared` (theme, network, offline cache, analytics)

## Theme UI
- Couleur principale: bleu clair.
- Couleur d'accent: orange.
- Design moderne, cartes dynamiques, widget intelligent sur l'accueil.

