# Gamification et rétention

## Objectif
Faire revenir l’élève chaque jour avec des boucles courtes et utiles.

## Mécaniques livrées
- Check-in quotidien (+20 XP).
- Streak journalier et meilleur streak.
- Niveau calculé par XP.
- Quêtes quotidiennes (cours, QCM, révision).

## Côté base de données
- `gamification_profiles`
- `daily_quests`
- `quest_completions`
- RPC `claim_daily_checkin()`

## Côté application
- Panneau gamification sur l’accueil.
- Progression visible (barre XP + niveau).
- Liste de quêtes avec état complété du jour.
- Bouton check-in avec feedback immédiat.

## Fichiers
- Migration: `backend/migrations/0008_gamification.sql`
- Seed quêtes: `backend/migrations/0009_seed_daily_quests.sql`
- Schéma clean: `backend/schema/09_gamification.sql`
- Schéma clean seed: `backend/schema/10_seed_daily_quests.sql`

