import 'package:flutter/material.dart';
import '../../domain/quiz_content_block.dart';
import '../constants.dart';
import 'content_block_renderer.dart';
import '../quiz_icons.dart';

/// Shows correct/incorrect feedback after answering a question.
class FeedbackBanner extends StatelessWidget {
  const FeedbackBanner({
    super.key,
    required this.correct,
    this.explanation = const [],
    this.showAnswer = false,
    this.correctAnswer,
    this.neutral = false,
    this.neutralMessage,
  });

  final bool correct;
  final List<ContentBlock> explanation;
  final bool showAnswer;
  final String? correctAnswer;

  /// Etat système (temps écoulé, réponse non notable) — ni succès ni échec,
  /// affiché même si feedbackMode != immediate (ce n'est pas une correction).
  final bool neutral;
  final String? neutralMessage;

  @override
  Widget build(BuildContext context) {
    final color = neutral ? gold500 : (correct ? success600 : error400);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, -20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: cardBorderRadius,
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  neutral
                      ? QuizIcons.clock
                      : (correct ? QuizIcons.checkCircle : QuizIcons.cancel),
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    neutral
                        ? (neutralMessage ?? 'Réponse enregistrée')
                        : (correct ? 'Bonne réponse !' : 'Incorrect'),
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (explanation.isNotEmpty) ...[
              const SizedBox(height: 8),
              ContentBlockRenderer(
                blocks: explanation,
                textStyle: TextStyle(
                  color: cream700,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
            if (showAnswer && correctAnswer != null) ...[
              const SizedBox(height: 8),
              Text('Réponse : $correctAnswer',
                  style: TextStyle(
                      color: success600, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}
