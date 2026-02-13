# Home Widget (ecran d'accueil)

## Objectif
Permettre a l'utilisateur d'ajouter un widget EduQuest sur l'ecran du telephone.

## Ce que l'app fait deja
- Stocke des donnees widget (`eduquest_title`, `eduquest_subtitle`).
- Declenche un refresh widget via `home_widget`.
- Action exposee dans `Profil > Mettre a jour le widget ecran`.

## Variables `.env`
- `HOME_WIDGET_ANDROID_NAME`
- `HOME_WIDGET_IOS_NAME`

## A finaliser (natif)
1. Android: creer `AppWidgetProvider` et layout XML.
2. iOS: creer extension WidgetKit (SwiftUI).
3. Mapper les noms natifs avec les variables `.env`.

## Bonnes pratiques UX
- Widget utile: revision du jour + ticket expiration + concours.
- Mise a jour cadencee (pas trop frequente).
- Clic widget ouvre l'ecran pertinent dans l'app.

## Source officielle
- https://pub.dev/packages/home_widget

