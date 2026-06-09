import 'package:eduquest/features/learning/domain/qcm_question.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
      appBar: RuachAppBar(title: '${index + 1}/$total'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 4,
              backgroundColor: RuachColors.cream200,
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Icon(PhosphorIconsRegular.timer, size: 16, color: RuachColors.gold600),
            const SizedBox(width: 4),
            Text(
              '${left}s',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: RuachColors.cream900,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Text(
            question.prompt,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: RuachColors.cream900,
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
                      ? RuachColors.success600.withValues(alpha: .08)
                      : wrong
                          ? RuachColors.error400.withValues(alpha: .08)
                          : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(RuachRadius.md),
                  border: Border.all(
                    color: correct
                        ? RuachColors.success600
                        : wrong
                            ? RuachColors.error400
                            : o == selected
                                ? s.primary
                                : RuachColors.cream200,
                    width: o == selected || correct || wrong ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  o,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: RuachColors.cream900,
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
                    ? RuachColors.success600
                    : RuachColors.error400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
