import 'package:eduquest/features/surveys/domain/survey_question.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_chip.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:flutter/material.dart';

class OrientationPageBody extends StatelessWidget {
  const OrientationPageBody({
    super.key,
    required this.questions,
    required this.currentIndex,
    required this.answers,
    required this.sending,
    required this.result,
    required this.textController,
    required this.onAnswerSelected,
    required this.onNext,
  });

  final List<SurveyQuestion> questions;
  final int currentIndex;
  final Map<String, String> answers;
  final bool sending;
  final String result;
  final TextEditingController textController;
  final ValueChanged<String> onAnswerSelected;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final cur = questions[currentIndex];
    return ListView(padding: const EdgeInsets.all(20), children: [
      RuachProgressBar(value: (currentIndex + 1) / questions.length),
      const SizedBox(height: 12),
      Text(
        'Question ${currentIndex + 1} / ${questions.length}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: RuachColors.cream500,
          fontSize: 13,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        cur.prompt,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: RuachColors.cream900,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 14),
      if (cur.type == 'mcq')
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cur.options
              .map((o) => RuachChip(
                    label: o,
                    selected: answers[cur.id] == o,
                    onTap: () => onAnswerSelected(o),
                  ))
              .toList(),
        ),
      if (cur.type == 'text')
        TextField(
          controller: textController,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Ta reponse...'),
        ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: RuachButton(
          label: sending
              ? 'Analyse...'
              : (currentIndex == questions.length - 1 ? 'Terminer' : 'Suivant'),
          onPressed: sending ? null : onNext,
        ),
      ),
      if (result.isNotEmpty) ...[
        const SizedBox(height: 16),
        Text(
          result,
          style: const TextStyle(
            color: RuachColors.cream900,
            height: 1.5,
          ),
        ),
      ],
    ]);
  }
}
