# Execution Database Flow

## Flux actuel
Le projet est maintenant en mode `schema-only`.
Toutes les evolutions ont ete consolidees dans `backend/schema/*`.

## Reset complet de la base
Executer le schema clean dans l'ordre:
1. `backend/schema/01_core.sql`
2. `backend/schema/02_content.sql`
3. `backend/schema/03_access_marketing.sql`
4. `backend/schema/04_business.sql`
5. `backend/schema/05_analytics.sql`
6. `backend/schema/06_access_functions.sql`
7. `backend/schema/07_rls.sql`
8. `backend/schema/08_notifications.sql`
9. `backend/schema/09_gamification.sql`
10. `backend/schema/10_seed_daily_quests.sql`
11. `backend/schema/11_weekly_leaderboard_anticheat.sql`
12. `backend/schema/12_monthly_rewards_optional.sql`
13. `backend/schema/13_app_config_auth_update.sql`
14. `backend/schema/14_device_sessions.sql`
15. `backend/schema/15_legal_compliance.sql`
16. `backend/schema/16_seed_legal_docs.sql`
17. `backend/schema/17_data_governance_cron.sql`
18. `backend/schema/18_dynamic_classes_ticket_transfer.sql`
19. `backend/schema/19_togo_bootstrap.sql`
20. `backend/schema/20_engagement_referral_rpcs.sql`
21. `backend/schema/21_profile_scope_policies.sql`
22. `backend/schema/22_marketplace_search.sql`
23. `backend/schema/23_seed_realistic_demo.sql` (optionnel: données de démonstration)
24. `backend/schema/24_surveys_form.sql`
25. `backend/schema/25_seed_tg_content_matrix.sql` (optionnel: seed pédagogique élargi)

## Regle d'or
- Toute nouvelle feature qui touche la DB doit livrer:
  - mise a jour schema clean,
  - script de transition documente si la base existe deja.

## Scripts consolides ajoutes au schema
26. `backend/schema/26_profile_setup.sql`
27. `backend/schema/27_reminder_badge_support.sql`
28. `backend/schema/28_contests_presence_mode.sql`
29. `backend/schema/29_referral_rewards_auto.sql`
30. `backend/schema/30_activate_ticket_guard_reward_hook.sql`
31. `backend/schema/31_gamification_checkin_hardening.sql`
32. `backend/schema/32_seed_data_and_ticket.sql` (optionnel: seed + ticket user)
33. `backend/schema/33_seed_massif_ultra_tg.sql` (optionnel: seed massif réaliste TG)
