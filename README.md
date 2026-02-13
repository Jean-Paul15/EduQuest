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
   - `SUPABASE_ANON_KEY`
   - `SUPABASE_OAUTH_REDIRECT_URL`
   - `ONESIGNAL_APP_ID`
3. Auth activee: Google + Apple uniquement (pas OTP/email/mdp).

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
