# Realtime, chargement progressif, offline

## Chargement progressif
- L’app ne construit plus tous les écrans au lancement.
- Navigation lazy avec cache par onglet (`MainNavPage`).
- Chaque écran charge ses données au moment où il est ouvert.

## Realtime ciblé
- `Home` ouvre un canal Realtime Supabase uniquement quand l’écran est actif.
- Écoute: `gamification_profiles`, `ticket_codes` filtrés par utilisateur.
- Si DB change: seul `Home` se rafraîchit.
- À la fermeture écran: suppression du canal.

## Offline PDF chiffré
- Les PDF sont stockés chiffrés localement (AES) dans un dossier app.
- À changement de version: nouveau fichier sauvegardé, ancien supprimé.
- Aucun contenu PDF en clair dans le stockage utilisateur.
- Onglet `Cours`: téléchargement auto à la 1re ouverture + refresh silencieux via Realtime.

## Fichiers
- `lib/features/navigation/presentation/main_nav_page.dart`
- `lib/features/home/presentation/home_controller.dart`
- `lib/features/offline/data/encrypted_pdf_cache.dart`
- `lib/features/offline/data/pdf_offline_repository.dart`
- `lib/features/learning/presentation/pages/pdf_lessons_page.dart`
