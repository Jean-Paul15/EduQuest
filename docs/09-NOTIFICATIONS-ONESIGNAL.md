# Notifications OneSignal

## Objectif
Envoyer des notifications utiles, pas du spam: revision, concours, cours live, evenements, expiration ticket.

## Segmentation
- Tags minimaux: `country`, `level`, `serie`.
- Topics: `topic_revision`, `topic_contest`, `topic_event`.
- Statut acces: `ticket_tier` (`FREE`, `HALF`, `FULL`).

## Triggers
- Rappel revision quotidien configurable.
- Alerte concours avant deadline.
- Alerte evenement avec lien pass.
- Alerte ticket proche expiration (J-7, J-1).

## Technique
- App initialise OneSignal au demarrage.
- User lie via `external user id` (uid Supabase).
- Envoi centralise cote serveur/site admin via API OneSignal.

## Regles qualite
- Frequence max par type.
- Desabonnement possible par categorie.
- Tracking ouverture/clic dans `app_events`.

