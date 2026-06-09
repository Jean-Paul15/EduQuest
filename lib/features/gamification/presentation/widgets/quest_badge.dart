import 'package:eduquest/features/gamification/domain/daily_quest.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class QuestBadge extends StatelessWidget {
  const QuestBadge({super.key, required this.quest});
  final DailyQuest quest;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: quest.completedToday
            ? RuachColors.success600.withValues(alpha: .08)
            : s.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(RuachRadius.sm),
        border: Border.all(
          color: quest.completedToday
              ? RuachColors.success600.withValues(alpha: .2)
              : RuachColors.cream200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            quest.completedToday
                ? PhosphorIconsRegular.checkCircle
                : PhosphorIconsRegular.circle,
            size: 14,
            color: quest.completedToday ? RuachColors.success600 : RuachColors.cream700,
          ),
          const SizedBox(width: 4),
          Text(
            '${quest.label} +${quest.xpReward}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: quest.completedToday ? RuachColors.success600 : RuachColors.cream500,
            ),
          ),
        ],
      ),
    );
  }
}
