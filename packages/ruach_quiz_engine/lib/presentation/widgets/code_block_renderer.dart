import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../../domain/quiz_content_block.dart';

/// Rendu de bloc de code avec coloration syntaxique.
class CodeBlockRenderer extends StatelessWidget {
  const CodeBlockRenderer(this.block, {super.key});
  final CodeBlock block;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: HighlightView(
          block.value,
          language: block.language,
          theme: atomOneDarkTheme,
          padding: const EdgeInsets.all(12),
          textStyle: const TextStyle(
              fontFamily: 'JetBrainsMono', fontSize: 13, height: 1.5),
        ),
      ),
    );
  }
}
