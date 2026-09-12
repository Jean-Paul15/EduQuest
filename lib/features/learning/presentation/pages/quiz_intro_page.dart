import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Écran "Prêt à commencer ?" poussé avant d'entrer dans un quiz — donne le
/// contexte (nombre de questions, reprise possible) plutôt que de sauter
/// directement dans le quiz sans préambule.
class QuizIntroPage extends StatelessWidget {
  const QuizIntroPage({
    super.key,
    required this.quizId,
    required this.title,
    this.questionCount,
    this.timePerQuestionSeconds,
    this.hasSavedProgress = false,
  });
  final String quizId;
  final String title;
  final int? questionCount;
  final int? timePerQuestionSeconds;
  final bool hasSavedProgress;

  void _start(BuildContext context) => context.pushReplacementNamed(
        AppRoutes.qcmAttempt,
        pathParameters: {'quizId': quizId},
        queryParameters: {'title': title},
      );

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: RuachAppBar(title: title, showBack: true),
      body: Padding(
        padding: const EdgeInsets.all(RuachSpace.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(RuachSpace.s4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(color: s.outlineVariant),
                borderRadius: BorderRadius.circular(RuachRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasSavedProgress) ...[
                    Row(children: [
                      Icon(PhosphorIconsRegular.playCircle, color: s.primary, size: 20),
                      const SizedBox(width: RuachSpace.s2),
                      Text('Tu as une tentative en cours',
                          style: Theme.of(context).textTheme.titleSmall),
                    ]),
                    const SizedBox(height: RuachSpace.s2),
                    Text('Reprends exactement où tu t\'es arrêté(e).',
                        style: TextStyle(color: s.onSurfaceVariant)),
                  ] else ...[
                    Text('Avant de commencer', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: RuachSpace.s3),
                    if (questionCount != null)
                      _Rule(icon: PhosphorIconsRegular.listChecks, text: '$questionCount questions'),
                    if (timePerQuestionSeconds != null)
                      _Rule(icon: PhosphorIconsRegular.timer, text: '$timePerQuestionSeconds s par question'),
                    _Rule(icon: PhosphorIconsRegular.floppyDisk, text: 'Ta progression est sauvegardée automatiquement'),
                  ],
                ],
              ),
            ),
            const Spacer(),
            RuachButton(
              label: hasSavedProgress ? 'Reprendre' : 'Commencer',
              icon: PhosphorIconsRegular.playCircle,
              onPressed: () => _start(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: RuachSpace.s2),
      child: Row(children: [
        Icon(icon, size: 16, color: s.onSurfaceVariant),
        const SizedBox(width: RuachSpace.s2),
        Expanded(child: Text(text, style: TextStyle(color: s.onSurfaceVariant))),
      ]),
    );
  }
}
