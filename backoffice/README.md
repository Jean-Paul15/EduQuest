# Backoffice EduQuest

## But
Piloter toute l'administration depuis une interface web moderne:
- rôles dynamiques,
- permissions,
- sections sidebar,
- accès des équipes,
- support et conformité.

## Stack
- Next.js (App Router)
- React
- Refine (shell backoffice)
- UI style shadcn (composants `ui/*`)
- Supabase (RLS + RPC)

## SQL à exécuter (ordre)
1. `backend/schema_compact/66_backoffice_rbac_core.sql`
2. `backend/schema_compact/67_backoffice_rbac_functions.sql`
3. `backend/schema_compact/68_backoffice_rbac_rls.sql`
4. `backend/schema_compact/69_backoffice_rbac_seed.sql`

## Routes clés
- `/backoffice`
- `/backoffice/dashboard`
- `/backoffice/rbac`
- `/backoffice/reset-password`

## Règles importantes
- Aucun profil fixe côté UI: RBAC 100% dynamique.
- Un utilisateur voit uniquement ses sections autorisées.
- Première connexion: changement mot de passe obligatoire si flag activé.
