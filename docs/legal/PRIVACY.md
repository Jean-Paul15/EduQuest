# Politique de confidentialité EduQuest

## 1. Données collectées
- Identifiants de compte et profil scolaire.
- Données d’usage (progression, activité, engagement).
- Données sécurité (session appareil, anti-fraude).

## 2. Finalités
- Personnalisation de l’expérience.
- Sécurité, anti-abus, amélioration produit.
- Pilotage pédagogique et opérationnel.

## 3. Base légale et transparence
- Consentement pour documents légaux versionnés.
- Minimisation et proportionnalité des données collectées.

## 4. Conservation
- Rétention pilotée par `data_retention_policies`.
- Purge automatique via `run_data_retention()` (cron).
- En cas d’inactivité prolongée, suppression complète des données applicatives après 6 mois.

## 5. Droits des utilisateurs
- Accès, rectification, suppression selon le droit applicable.
- Demandes traitées par l’équipe support EduQuest.

## 6. Sécurité
- RLS, journal d’audit, session mono-appareil.
- Cache local PDF chiffré côté application.
