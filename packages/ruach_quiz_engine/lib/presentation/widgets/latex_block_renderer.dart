import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../domain/quiz_content_block.dart';
import '../constants.dart';

/// Rendu LaTeX inline et display.
class LatexBlockRenderer extends StatelessWidget {
  const LatexBlockRenderer(this.block, {super.key});
  final LatexBlock block;

  @override
  Widget build(BuildContext context) {
    try {
      final widget = block.display
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ink800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Math.tex(
                    block.formula,
                    textStyle: TextStyle(fontSize: 20, color: cream900),
                    mathStyle: MathStyle.display,
                  ),
                ),
              ),
            )
          : Math.tex(
              block.formula,
              textStyle: TextStyle(fontSize: 16, color: cream900),
              mathStyle: MathStyle.text,
            );
      return Semantics(
        label: block.semanticLabel,
        child: widget,
      );
    } catch (_) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(block.formula,
          style: TextStyle(fontFamily: 'monospace', color: cream700)),
      );
    }
  }
}
