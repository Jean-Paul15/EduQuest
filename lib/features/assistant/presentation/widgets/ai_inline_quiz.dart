import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:flutter/material.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

/// Quiz interactif joué directement dans une bulle de chat, sans Scaffold dédié —
/// composition manuelle (QuestionCard + QuizSessionController) comme dans
/// OrientationPage en mode embedded, pas QuizScreen qui impose un écran plein.
class AiInlineQuiz extends StatefulWidget {
  const AiInlineQuiz({
    super.key,
    required this.definitionJson,
    required this.onCompleted,
  });

  final Map<String, dynamic> definitionJson;
  final void Function(QuizResult result, QuizDefinition definition) onCompleted;

  @override
  State<AiInlineQuiz> createState() => _AiInlineQuizState();
}

class _AiInlineQuizState extends State<AiInlineQuiz> {
  QuizSessionController? _controller;
  String? _error;
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    try {
      final definition = const QdlParser().parseFull(widget.definitionJson);
      final controller = QuizSessionController(definition: definition);
      controller.addListener(_onChange);
      controller.start();
      _controller = controller;
    } catch (_) {
      _error = 'Ce quiz n\'a pas pu être chargé.';
    }
  }

  void _onChange() {
    if (!mounted) return;
    setState(() {});
    final controller = _controller;
    if (!_reported &&
        controller != null &&
        controller.state == QuizSessionState.completed &&
        controller.result != null) {
      _reported = true;
      widget.onCompleted(controller.result!, controller.definition);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onChange);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _advance() async {
    final controller = _controller;
    if (controller == null || !controller.locked) return;
    final isLast = controller.currentIndex == controller.definition.totalQuestions - 1;
    if (isLast) {
      await controller.finish();
      return;
    }
    controller.next();
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error));
    }
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();

    if (controller.state == QuizSessionState.completed && controller.result != null) {
      final result = controller.result!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: RuachSpace.s2),
          Text(
            '${result.correctCount}/${result.totalQuestions} correctes · ${result.scorePercent.round()}%',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: RuachSpace.s2),
        RuachProgressBar(
          value: (controller.currentIndex + 1) / controller.definition.totalQuestions,
        ),
        const SizedBox(height: RuachSpace.s3),
        QuestionCard(
          question: controller.currentQuestion,
          locked: controller.locked,
          editable: controller.editable,
          selectedAnswer: controller.selectedAnswer,
          onAnswer: controller.answer,
        ),
        const SizedBox(height: RuachSpace.s3),
        RuachButton(
          label: controller.currentIndex == controller.definition.totalQuestions - 1
              ? 'Voir mon score'
              : 'Continuer',
          onPressed: controller.locked ? _advance : null,
        ),
      ],
    );
  }
}
