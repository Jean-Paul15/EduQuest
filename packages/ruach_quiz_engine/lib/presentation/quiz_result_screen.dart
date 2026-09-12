import 'package:flutter/material.dart';
import '../domain/quiz_result.dart';
import '../domain/quiz_content_block.dart';
import 'constants.dart';
import 'widgets/score_circle.dart';
import 'widgets/missed_review_list.dart';
import 'widgets/content_badges_row.dart';
import 'widgets/quiz_action_button.dart';
import 'widgets/quiz_surface_panel.dart';
import 'quiz_icons.dart';

/// Full-screen result view displayed when a quiz is completed.
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key, required this.result,
    required this.onRetry, required this.onClose,
    this.contentBadges = const [],
    this.showCorrections = true,
  });
  final QuizResult result;
  final VoidCallback onRetry;
  final VoidCallback onClose;
  final List<ContentTypeBadge> contentBadges;

  /// false pour un quiz en FeedbackMode.never (ex. orientation) — ne révèle
  /// jamais les bonnes réponses, même en fin de parcours.
  final bool showCorrections;

  String get _time => result.totalTimeSeconds >= 60
      ? '${result.totalTimeSeconds ~/ 60} min ${result.totalTimeSeconds % 60} s'
      : '${result.totalTimeSeconds} s';

  @override
  Widget build(BuildContext context) {
    final passed = result.passed;
    final color = passed ? success600 : error400;
    return Scaffold(
      backgroundColor: ink900,
      appBar: AppBar(
        backgroundColor: ink800,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 8,
        leadingWidth: 56,
        title: Text(
          'Résultat',
          style: TextStyle(
            color: cream900,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(QuizIcons.closeBold, color: cream700, size: 20),
          onPressed: onClose,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          QuizSurfacePanel(
            child: Column(children: [
              ScoreCircle(percent: result.scorePercent, passed: passed),
              const SizedBox(height: 8),
              if (passed) _validationBadge(),
              Text(passed ? 'Félicitations !' : 'Continuez vos efforts',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stat('Correct', result.correctCount, success600,
                      QuizIcons.checkCircle),
                  _stat('Incorrect', result.wrongCount, error400, QuizIcons.cancel),
                  _stat('Passés', result.skippedCount, cream700, QuizIcons.skipNext),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: surfaceBase,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: surfaceStroke),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(QuizIcons.timer,
                      color: cream700, size: 16),
                  const SizedBox(width: 6),
                  Text(_time,
                      style:
                          TextStyle(color: cream700, fontSize: 13)),
                ]),
              ),
              ContentBadgesRow(badges: contentBadges),
            ]),
          ),
          if (showCorrections && result.perQuestion.any((q) => !q.correct))
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: QuizSurfacePanel(
                child: MissedReviewList(perQuestion: result.perQuestion),
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: QuizActionButton(label: 'Recommencer', onPressed: onRetry),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: QuizActionButton(
              label: 'Terminer',
              primary: false,
              onPressed: onClose,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _validationBadge() => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(QuizIcons.star, color: gold500, size: 20),
    const SizedBox(width: 6),
    Text('Quiz validé',
        style: TextStyle(color: gold500, fontSize: 14,
            fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
  ]);
  Widget _stat(String label, int count, Color color, IconData icon) =>
      Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text('$count', style: TextStyle(color: color, fontSize: 20,
            fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: cream700, fontSize: 11)),
      ]);
}
