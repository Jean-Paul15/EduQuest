import 'dart:ui';

import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

/// Conteneur glassmorphisme reutilisable
/// Fond flou semi-transparent avec bordure lumineuse
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.blur = 14.0,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [
                  Colors.white.withValues(alpha: 0.07),
                  Colors.white.withValues(alpha: 0.03),
                ]
              : [
                  Colors.white.withValues(alpha: 0.6),
                  Colors.white.withValues(alpha: 0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(
          color: (dark ? Colors.white : AppColors.primary).withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.l),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
