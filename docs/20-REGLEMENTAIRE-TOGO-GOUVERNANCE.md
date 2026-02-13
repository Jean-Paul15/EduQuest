# Réglementaire Togo et gouvernance données

## Cadre de référence (à valider juridiquement)
- Loi togolaise sur la protection des données personnelles.
- Obligations: finalité, proportionnalité, sécurité, droits des personnes.
- Bonnes pratiques alignées RGPD pour faciliter extension multi-pays.

## Gouvernance implémentée
- Versionnage documents légaux (`legal_documents`).
- Consentement horodaté utilisateur (`user_legal_consents`).
- Rétention paramétrable (`data_retention_policies`).
- Journal d’audit conformité (`compliance_audit_logs`).

## Purge et cron
- Fonction: `run_data_retention()`.
- Planification quotidienne via `pg_cron` si extension active.
- Suppression des données inactives selon politique.

## Recommandations prod
- Revue avocat local Togo avant lancement public.
- Registre des traitements + DPA partenaires.
- Procédure incidents/signalement + délai de notification.

## Sources de travail
- https://www.ilo.org/dyn/natlex/natlex4.detail?p_lang=fr&p_isn=111148
- https://www.droit-afrique.com/uploads/Togo-Loi-2019-014-protection-donnees-caractere-personnel.pdf

