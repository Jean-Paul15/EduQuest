# Anti-capture (ecrans sensibles)

## Ecrans proteges
- `Apprendre` (tabs Cours, Exercices, Corrections, QCM).
- `Cours Protege` (detail contenu sensible).

## Implementation Flutter
- Wrapper reutilisable: `lib/shared/security/sensitive_scope.dart`.
- Service securite: `lib/shared/security/sensitive_guard.dart`.
- Plugin: `screen_protector`.

## Effets actifs
- Blocage capture ecran.
- Reduction fuite visuelle en background via blur.

## Regle produit
- Appliquer `SensitiveScope` a tout ecran sensible:
  - cours PDF/video,
  - quiz/QCM,
  - epreuves et corrections.

## Limites pratiques
- Le niveau exact de protection depend du systeme et de l'appareil.
- Toujours combiner avec watermark, controle acces, et logs d'usage.

## Source
- https://pub.dev/packages/screen_protector

