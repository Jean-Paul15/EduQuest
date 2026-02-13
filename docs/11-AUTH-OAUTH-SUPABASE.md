# Auth OAuth Supabase (Google + Apple uniquement)

## Regle produit
- Pas d'OTP.
- Pas email/mot de passe.
- Connexion uniquement via Google et Apple.

## Variables `.env`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_OAUTH_REDIRECT_URL` (ex: `eduquest://login-callback`)

## Cote Supabase Dashboard
1. Activer provider Google dans `Authentication > Providers`.
2. Activer provider Apple dans `Authentication > Providers`.
3. Ajouter URL de redirection autorisee (mobile/web).

## Cote Flutter
- Methode utilisee: `signInWithOAuth`.
- Providers: `OAuthProvider.google`, `OAuthProvider.apple`.
- Mobile: ouverture externe (`LaunchMode.externalApplication`).
- Web: flow standard navigateur.

## Deep links
- Android: intent-filter scheme `eduquest`.
- iOS: URL Types scheme `eduquest`.
- Web: URL callback definie dans Supabase.

## Sources officielles
- https://supabase.com/docs/guides/auth/social-login/auth-google
- https://supabase.com/docs/guides/auth/social-login/auth-apple
- https://supabase.com/docs/reference/dart/auth-signinwithoauth
- https://supabase.com/docs/guides/auth/native-mobile-deep-linking

