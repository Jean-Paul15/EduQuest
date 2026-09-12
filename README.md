# EduQuest

EduQuest est une application educative orientee Afrique (demarrage Togo), avec backend Supabase et front Flutter (web, Android, iOS).

## Lancer le projet

```bash
flutter pub get
flutter run -d chrome
```

## Configuration `.env`

1. Copier `.env.example` en `.env`.
2. Renseigner:
   - `SUPABASE_URL`
   - `SUPABASE_PUBLISHABLE_KEYS`
   - `SUPABASE_OAUTH_REDIRECT_URL`
   - `ONESIGNAL_APP_ID`
3. Les secrets IA (`OPENAI_API_KEY`, `DEEPSEEK_API_KEY`) restent dans Supabase Vault.
4. Crashlytics utilise `lib/firebase_options.dart` genere via `flutterfire configure`.
5. Auth activee: Google + Apple uniquement (pas OTP/email/mdp).

## Push OneSignal

- SDK Flutter initialise avant `runApp()` via `NotificationService`.
- SDK Flutter: `onesignal_flutter` `5.3.5` (track stable officiel).
- App ID configure: `a233937a-3480-429f-882a-02288cacb92b`.
- Android push reel: ajouter `android/app/google-services.json`.
- iOS push: entitlement `aps-environment` versionne + `remote-notification` deja declare.
- iOS push reel: verifier la signature Apple/Xcode et charger la cle APNs dans OneSignal.

## Documentation projet

- `AGENTS.md`: guide de collaboration pour IA/agents.
- `CLAUDE.md`: manuel d'execution.
- `docs/`: specifications fonctionnelles, strategie acces, offline, analytics.
- `backend/schema/`: schema SQL Supabase decoupe par domaine.
- `docs/11-AUTH-OAUTH-SUPABASE.md`: setup OAuth officiel.
- `docs/12-HOME-WIDGET.md`: setup widget ecran accueil.

## Themes UI

- Bleu clair principal: `#2F80ED`
- Orange accent: `#F2994A`
