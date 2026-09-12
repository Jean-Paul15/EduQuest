import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

/// Slide d'onboarding plein cadre : photo en fond, scrim (dégradé sombre)
/// pour garantir le contraste du texte, badge icône + titre + description
/// épinglés en bas. Pattern standard des onboardings à base de photo —
/// voir sources dans le plan de la session (Smashing Magazine, iamsuleiman.com).
class IntroSlideVisual extends StatelessWidget {
  const IntroSlideVisual({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.imagePath,
  });

  final String title;
  final String description;
  final IconData icon;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final tx = Theme.of(context).textTheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) =>
              ColoredBox(color: RuachColors.ink200),
        ),
        // Voile de base pour l'homogénéité avec le thème sombre de l'app,
        // plus un dégradé qui s'assombrit vers le bas où vit le texte.
        const DecoratedBox(
          decoration: BoxDecoration(color: Colors.black26),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black],
              stops: [0.35, 1.0],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              RuachSpace.s6, 0, RuachSpace.s6, RuachSpace.s8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(RuachSpace.s3),
                  decoration: BoxDecoration(
                    color: RuachColors.gold500.withValues(alpha: .9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: RuachColors.ink200, size: 22),
                ),
                const SizedBox(height: RuachSpace.s4),
                Text(
                  title,
                  style: tx.headlineLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: RuachSpace.s3),
                Text(
                  description,
                  style: tx.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: .88),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
