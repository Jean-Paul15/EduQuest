import 'package:eduquest/features/learning/domain/qcm_question.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class QcmQuestionStage extends StatelessWidget {
  const QcmQuestionStage({
    super.key,
    required this.title,
    required this.index,
    required this.total,
    required this.left,
    required this.question,
    required this.locked,
    required this.selected,
    required this.timeout,
    required this.onPick,
  });

  final String title;
  final int index;
  final int total;
  final int left;
  final QcmQuestion question;
  final bool locked;
  final String? selected;
  final bool timeout;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final ratio = (index + 1) / total;
    final msg = timeout
        ? 'Temps ecoule.'
        : locked
            ? (selected == question.answer
                ? 'Bonne reponse !'
                : 'Reponse: ${question.answer}')
            : '';
    return Scaffold(
      appBar: AppBar(title: Text('${index + 1}/$total')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 4,
              backgroundColor: AppColors.divider,
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.timer_outlined, size: 16, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(
              '${left}s',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Text(
            question.prompt,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...question.options.map((o) {
            final correct = locked && o == question.answer;
            final wrong = locked && o == selected && o != question.answer;
            return GestureDetector(
              onTap: locked ? null : () => onPick(o),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: correct
                      ? AppColors.success.withValues(alpha: .08)
                      : wrong
                          ? AppColors.error.withValues(alpha: .08)
                          : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.s),
                  border: Border.all(
                    color: correct
                        ? AppColors.success
                        : wrong
                            ? AppColors.error
                            : o == selected
                                ? s.primary
                                : AppColors.divider,
                    width: o == selected || correct || wrong ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  o,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }),
          if (msg.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              msg,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: locked && selected == question.answer
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
