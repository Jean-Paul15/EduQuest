# Leaderboard hebdo + récompenses mensuelles

## Classement hebdomadaire
- Généré par `build_weekly_leaderboard()`.
- Score basé sur activité utile (quiz/check-in valorisés).
- Stocké dans `weekly_leaderboards`.

## Anti-triche minimal
- Seuil activité: `min_activity_events`.
- Exclusion comportements anormaux: `max_events_per_day`.
- Règles modifiables via `anti_cheat_rules`.

## Récompenses mensuelles (optionnelles)
- Pilotées par `monthly_reward_policies.enabled`.
- Si `enabled=false`: classement visible sans récompense.
- Si `enabled=true`: résultats marqués `reward_granted=true`.

## Fonctions SQL
- `build_weekly_leaderboard(p_period_key)`
- `build_monthly_reward_results(p_period_key)`

## Fichiers
- `backend/migrations/0010_weekly_leaderboard_anticheat.sql`
- `backend/migrations/0011_monthly_rewards_optional.sql`
- `backend/schema/11_weekly_leaderboard_anticheat.sql`
- `backend/schema/12_monthly_rewards_optional.sql`

