import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

/// Une question du test, avec l'entête du bloc, la croix pour quitter et une
/// progression **interne au bloc** (étapes franchissables, pas un total brut).
class OrientationQuestionFlow extends StatelessWidget {
  const OrientationQuestionFlow({
    super.key,
    required this.controller,
    required this.onAnswer,
    required this.onNext,
    required this.onExit,
  });
  final QuizSessionController controller;
  final ValueChanged<QuizAnswer> onAnswer;
  final VoidCallback onNext, onExit;

  @override
  Widget build(BuildContext context) {
    final group = controller.definition.groupFor(controller.currentQuestion.id);
    final ids = controller.definition.questions
        .where((q) => q.groupId == group?.id)
        .toList(growable: false);
    final localIndex =
        ids.indexWhere((q) => q.id == controller.currentQuestion.id) + 1;
    final isLast =
        controller.currentIndex == controller.definition.totalQuestions - 1;
    return ListView(
      padding: const EdgeInsets.all(RuachSpace.s4),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                group?.title ?? 'Bloc',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Semantics(
              button: true,
              label: 'Quitter le test',
              child: IconButton(
                icon: const Icon(PhosphorIconsRegular.x),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                onPressed: onExit,
              ),
            ),
          ],
        ),
        const SizedBox(height: RuachSpace.s2),
        Text(
          'Question $localIndex sur ${ids.length} dans ce bloc.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: RuachSpace.s3),
        RuachProgressBar(value: ids.isEmpty ? 0 : localIndex / ids.length),
        const SizedBox(height: RuachSpace.s4),
        QuestionCard(
          question: controller.currentQuestion,
          locked: controller.locked,
          editable: controller.editable,
          selectedAnswer: controller.selectedAnswer,
          onAnswer: onAnswer,
        ),
        const SizedBox(height: RuachSpace.s4),
        RuachButton(
          label: isLast ? 'Voir mon bilan' : 'Continuer',
          onPressed: controller.locked ? onNext : null,
        ),
      ],
    );
  }
}
