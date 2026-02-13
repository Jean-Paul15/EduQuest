# Implementation Status

## Implémenté et validé (build/test)
- Auth Google/Apple + Email/Mot de passe activable via `app_config.auth_options`.
- Navigation multi-onglets moderne + thème clair/sombre.
- Feed personnalisé classe/série.
- Espace apprentissage tabbar + PDF hors-ligne chiffré + refresh silencieux.
- Tickets (activation code RPC, FULL/HALF, contrôle d’accès).
- Changement de classe/série dynamique avec validation backend.
- Vidéos par chapitre (YouTube possible) filtrées par niveau/série actifs.
- Hub Concours/Événements/Enquêtes + préférences notifications OneSignal.
- Détail concours/événements + inscription via RPC (règles ticket incluses).
- Parrainage complet (code perso, application code, compteur d’invités).
- Marketplace opérationnel (catalogue, panier simple, checkout externe).
- Orientation Gemini (clé API via `.env`).
- Pages légales Markdown + consentement légal versionné en base.
- Anti-capture sur sections sensibles.
- Leaderboard hebdo + anti-triche minimal + récompenses mensuelles optionnelles.
- Exercices/Corrections/QCM alimentés DB (fin du placeholder statique).
- Gouvernance des données + purge inactivité 6 mois + cron DB.

## Vérification technique
- `flutter analyze` : OK.
- `flutter test` : OK.
- Contraintes de structure : aucun fichier `.dart/.sql/.md` > 100 lignes.

## Reste avant go-live réel
- Configurer toutes les clés `.env` + URLs stores.
- Activer providers Supabase (Google, Apple, Email) dans dashboard.
- Publier politiques légales finales validées juridique.
- Mettre observabilité prod (crash, logs, alertes) et backup/recovery.
