import 'package:eduquest/features/surveys/domain/survey_question.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SurveyQuestionCard extends StatelessWidget {
  const SurveyQuestionCard({
    super.key,
    required this.question,
    required this.selectedChoice,
    required this.controller,
    required this.answered,
    required this.onChoiceSelected,
  });
  final SurveyQuestion question;
  final String? selectedChoice;
  final TextEditingController controller;
  final bool answered;
  final ValueChanged<String> onChoiceSelected;
  @override
  Widget build(BuildContext context) {
    final q = question;
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: RuachColors.cream200),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.prompt,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: RuachColors.cream900,
            ),
          ),
          const SizedBox(height: RuachSpace.s2),
          if (q.type == 'mcq') _mcqChips(context),
          if (q.type == 'text') _textField(),
          const SizedBox(height: RuachSpace.s1),
          _answerStatus(),
        ],
      ),
    );
  }
  Widget _mcqChips(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: question.options.map((o) {
        final selected = selectedChoice == o;
        return ChoiceChip(
          label: Text(o),
          selected: selected,
          showCheckmark: false,
          selectedColor: RuachColors.gold500,
          backgroundColor: dark ? RuachColors.ink300 : RuachColors.cream50,
          side: BorderSide(
            color: selected ? RuachColors.gold500 : RuachColors.cream200,
          ),
          labelStyle: TextStyle(
            color: selected
                ? RuachColors.white
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (_) => onChoiceSelected(o),
        );
      }).toList(),
    );
  }
  Widget _textField() => TextField(
    controller: controller,
    minLines: 2,
    maxLines: 4,
    decoration: const InputDecoration(hintText: 'Ta reponse...'),
  );
  Widget _answerStatus() {
    return Row(
      children: [
        Icon(
          answered
              ? PhosphorIconsRegular.checkCircle
              : PhosphorIconsRegular.circle,
          size: 16,
          color: answered ? RuachColors.success600 : RuachColors.cream700,
        ),
        const SizedBox(width: 6),
        Text(
          answered ? 'Répondu' : 'À compléter',
          style: const TextStyle(fontSize: 12, color: RuachColors.cream500),
        ),
      ],
    );
  }
}
