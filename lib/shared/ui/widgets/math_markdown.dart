import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

/// Rendu Markdown + formules LaTeX pour les réponses de l'assistant.
///
/// Délimiteurs acceptés : `$…$`, `$$…$$`, `\(…\)`, `\[…\]`. Le rendu passe par
/// flutter_math_fork (sous-ensemble KaTeX : intégrales, sommes, produits,
/// limites, dérivées, fractions, racines, matrices, systèmes). Une formule non
/// reconnue retombe automatiquement sur son texte brut — la bulle ne casse
/// jamais.
class MathMarkdown extends StatelessWidget {
  const MathMarkdown({super.key, required this.data, this.selectable = false});

  final String data;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = theme.textTheme.bodyMedium?.copyWith(height: 1.45);

    final markdown = GptMarkdown(
      data,
      style: body,
      useDollarSignsForLatex: true,
      textScaler: MediaQuery.textScalerOf(context),
      styleSheet: GptMarkdownStyleSheet(
        latex: LatexStyle(
          textStyle: body,
          // Une grande intégrale ou une matrice ne peut pas se replier : on la
          // fait défiler horizontalement au lieu de déborder de l'écran.
          scrollBlockHorizontally: true,
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          borderRadius: const Radius.circular(10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
      ),
    );

    return selectable ? SelectionArea(child: markdown) : markdown;
  }
}
