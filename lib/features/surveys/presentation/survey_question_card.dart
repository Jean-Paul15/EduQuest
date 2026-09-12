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
    final s = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: s.outlineVariant),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.prompt,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: s.onSurface,
            ),
          ),
          const SizedBox(height: RuachSpace.s2),
          if (q.type == 'mcq') _mcqChips(context, s),
          if (q.type == 'text') _textField(),
          const SizedBox(height: RuachSpace.s1),
          _answerStatus(s),
        ],
      ),
    );
  }
  Widget _mcqChips(BuildContext context, ColorScheme s) {
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
            color: selected ? RuachColors.gold500 : s.outlineVariant,
          ),
          labelStyle: TextStyle(
            color: selected
                ? RuachColors.white
                : s.onSurface,
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
    decoration: const InputDecoration(hintText: 'Ta réponse...'),
  );
  Widget _answerStatus(ColorScheme s) {
    return Row(
      children: [
        Icon(
          answered
              ? PhosphorIconsRegular.checkCircle
              : PhosphorIconsRegular.circle,
          size: 16,
          color: answered ? RuachColors.success600 : s.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          answered ? 'Répondu' : 'À compléter',
          style: TextStyle(fontSize: 12, color: s.onSurfaceVariant),
        ),
      ],
    );
  }
}
