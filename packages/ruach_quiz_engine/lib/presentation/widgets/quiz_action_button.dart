import 'package:flutter/material.dart';
import '../constants.dart';
import '../tokens.dart';
import 'quiz_tap_scale.dart';

/// Bouton d'action du quiz — aligné visuellement sur RuachButton/RuachOutlineButton
/// de l'app hôte (forme pilule, hauteur minimum, feedback tactile immédiat, état
/// loading), reconstruit ici car le package ne peut pas importer ces widgets
/// (dépendance circulaire).
class QuizActionButton extends StatelessWidget {
  const QuizActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.primary = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool primary;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final fill = primary
        ? (enabled ? gold500 : surfaceStroke)
        : Colors.transparent;
    final text = primary
        ? (enabled ? ink900 : cream500)
        : (enabled ? cream900 : cream500);
    final border = primary ? Colors.transparent : (enabled ? gold500 : surfaceStroke);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: QuizTapScale(
        onTap: enabled ? onPressed : null,
        // Hauteur fixe (min ET max identiques) -- jamais seulement une
        // hauteur minimale : quel que soit l'espace propose par un ancetre
        // (ex. bottomNavigationBar d'un Scaffold, dont la contrainte haute
        // est volontairement large), ce bouton ne grandit jamais au-dela de
        // sa taille prevue.
        child: SizedBox(
          height: primary ? 52 : 44,
          child: AnimatedContainer(
            duration: QuizMotion.tap,
            // Padding vertical reduit pour le bouton secondaire (44px de
            // haut) -- a 14 (comme le primaire, 52px), il ne restait que
            // 16px pour le texte, qui se retrouvait coupe verticalement.
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: primary ? 14 : 10),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(QuizRadius.full),
              border: Border.all(color: border, width: primary ? 1 : 1.5),
              boxShadow: enabled && primary
                  ? [BoxShadow(color: goldGlow, blurRadius: 12, offset: const Offset(0, 4))]
                  : null,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: QuizMotion.appear,
                child: loading
                    ? _QuizButtonLoader(key: const ValueKey('loading'), color: text)
                    : Row(
                        key: const ValueKey('label'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (leading != null) ...[leading!, const SizedBox(width: 8)],
                          Text(
                            label,
                            style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizButtonLoader extends StatefulWidget {
  const _QuizButtonLoader({super.key, required this.color});
  final Color color;
  @override
  State<_QuizButtonLoader> createState() => _QuizButtonLoaderState();
}

class _QuizButtonLoaderState extends State<_QuizButtonLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 28, height: 20,
    child: AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final active = (_c.value + index * .2) % 1;
          return Container(
            width: 6,
            height: 6 + (active < .5 ? active * 6 : (1 - active) * 6),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
          );
        }),
      ),
    ),
  );
}
