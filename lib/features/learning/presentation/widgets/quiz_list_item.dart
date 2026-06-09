import 'package:eduquest/features/learning/domain/learning_quiz.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class QuizListItem extends StatelessWidget {
  const QuizListItem({super.key, required this.quiz, required this.onTap});
  final LearningQuiz quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: RuachColors.cream200),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: RuachColors.gold500.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(RuachRadius.sm),
          ),
          child: const Icon(
            PhosphorIconsRegular.puzzlePiece,
            size: 20,
            color: RuachColors.gold500,
          ),
        ),
        title: Text(
          quiz.title,
          style: const TextStyle(
            color: RuachColors.cream900,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          PhosphorIconsRegular.caretRight,
          color: RuachColors.cream700,
        ),
        onTap: onTap,
      ),
    );
  }
}
