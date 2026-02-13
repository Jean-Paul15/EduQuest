# Auth, appareil unique, version app

## Auth pilotée backend
- Table `app_config` contient `auth_options`.
- On peut activer/désactiver Google, Apple, email+mot de passe sans rebuild app.

## Appareil unique (sans plan Pro)
- Table `user_device_sessions`.
- À la connexion: `claim_device_session(device_id, token)`.
- Toute autre session appareil du même compte est désactivée.
- Vérification runtime: `is_device_session_valid`.

## Politique de mise à jour
- `app_config.app_update_policy` stocke JSON Android/iOS.
- L’app compare `buildNumber` local avec la politique backend.
- Si obligatoire: écran blocage + redirection store.

## Fichiers
- `backend/migrations/0012_app_config_auth_update.sql`
- `backend/migrations/0013_device_sessions.sql`
- `lib/features/app_config/data/app_config_repository.dart`
- `lib/features/app_config/data/update_gate_service.dart`
- `lib/features/session/data/device_session_service.dart`

