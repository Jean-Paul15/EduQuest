# RLS et Securite Supabase

## Regle globale
- RLS active sur toutes les tables metier.
- Ecriture reservee aux roles `admin`, `editor`, `teacher` selon table.
- Lecture etendue aux eleves selon droits d'acces calcules.

## Politiques minimales
- `profiles`: utilisateur lit/edite son profil.
- `resources`, `quizzes`, `exam_papers`: lecture via fonction `can_access_scope(profile_id, scope)`.
- `ticket_codes`: activation par proprietaire uniquement.
- `app_events`: insertion par utilisateur connecte, lecture admin.
- `contest_entries`: insert/update self, lecture classement public limite.

## Fonctions SQL a creer
- `get_user_role(uid uuid) returns text`
- `resolve_access_scope(uid uuid) returns jsonb`
- `can_access_scope(uid uuid, target_scope jsonb) returns boolean`

## Securite operationnelle
- Logs d'activation ticket non supprimables.
- Rate limit sur activation code et parrainage.
- PII minimale (telephone hashable si possible).

