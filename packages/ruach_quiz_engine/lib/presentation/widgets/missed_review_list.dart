import 'package:flutter/material.dart';
import '../../domain/quiz_result.dart';
import '../constants.dart';

/// Liste des questions ratées avec leur réponse et la correction.
class MissedReviewList extends StatelessWidget {
  const MissedReviewList({super.key, required this.perQuestion});
  final List<QuestionResult> perQuestion;

  @override
  Widget build(BuildContext context) {
    final missed = perQuestion.where((q) => !q.correct).toList();
    if (missed.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Questions à réviser',
          style: TextStyle(color: cream900, fontSize: 15,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      ...missed.asMap().entries.map((entry) => _card(entry.key + 1, entry.value)),
    ]);
  }

  Widget _card(int index, QuestionResult r) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: ink800,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: error400.withAlpha(60)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: error400.withAlpha(24),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text('Q$index',
              style: TextStyle(
                color: error400,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              )),
        ),
        const Spacer(),
        Text('${r.timeSpentSeconds}s',
            style: TextStyle(color: cream700, fontSize: 11)),
      ]),
      if (r.userAnswer != null || r.correctAnswer != null)
        const SizedBox(height: 8),
      if (r.userAnswer != null) ...[
        Text('Votre réponse',
            style: TextStyle(color: cream700, fontSize: 11)),
        const SizedBox(height: 2),
        Text(r.userAnswer!,
            style: TextStyle(color: error400, fontSize: 13)),
      ],
      if (r.correctAnswer != null) ...[
        const SizedBox(height: 6),
        Text('Réponse correcte',
            style: TextStyle(color: cream700, fontSize: 11)),
        const SizedBox(height: 2),
        Text(r.correctAnswer!,
            style: TextStyle(color: success600, fontSize: 13)),
      ],
    ]),
  );
}
