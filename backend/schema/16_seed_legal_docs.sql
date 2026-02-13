insert into legal_documents(doc_type, version, locale, title, body_md, active) values
('terms','1.0.0','fr-TG','Conditions d''utilisation EduQuest',
'# Conditions d''utilisation
## Usage
- Usage personnel éducatif uniquement.
- Respect des contenus, enseignants et partenaires.
## Interdictions
- Partage non autorisé de compte, tickets ou supports protégés.
- Comportements frauduleux ou abusifs.
## Sanctions
- EduQuest peut suspendre ou limiter un compte en cas d''abus.
## Inactivité
- En cas d''inactivité continue de 6 mois, les données applicatives peuvent être purgées automatiquement.',true),
('privacy','1.0.0','fr-TG','Politique de confidentialité EduQuest',
'# Politique de confidentialité
## Données collectées
- Progression d''apprentissage et activité.
- Préférences et notifications.
- Données appareil et sécurité de session.
## Finalités
- Personnalisation de l''expérience.
- Sécurité, anti-fraude et amélioration continue.
## Droits utilisateur
- Accès, correction et suppression selon le cadre légal applicable.
## Conservation
- En cas d''inactivité prolongée, suppression complète des données applicatives après 6 mois.',true)
on conflict (doc_type, version, locale) do update set
  title = excluded.title,
  body_md = excluded.body_md,
  active = excluded.active;

