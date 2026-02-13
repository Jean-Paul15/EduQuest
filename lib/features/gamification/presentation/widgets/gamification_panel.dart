import 'package:eduquest/features/gamification/domain/daily_quest.dart';
import 'package:eduquest/features/gamification/domain/gamification_state.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class GamificationPanel extends StatelessWidget {
  const GamificationPanel({
    super.key,
    required this.state,
    required this.quests,
    required this.onCheckin,
  });

  final GamificationState state;
  final List<DailyQuest> quests;
  final Future<void> Function() onCheckin;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(
              'Niv. ${state.level}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${state.xp} XP',
              style: TextStyle(
                color: s.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.levelProgress,
              minHeight: 6,
              backgroundColor: AppColors.divider,
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 16,
              color: AppColors.accent,
            ),
            const SizedBox(width: 4),
            Text(
              '${state.streakDays}j',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Record: ${state.bestStreak}j',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ]),
          if (quests.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: quests
                  .map(
                    (q) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: q.completedToday
                            ? AppColors.success.withValues(alpha: .08)
                            : s.primary.withValues(alpha: .06),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        border: Border.all(
                          color: q.completedToday
                              ? AppColors.success.withValues(alpha: .2)
                              : AppColors.divider,
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                          q.completedToday
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked,
                          size: 14,
                          color: q.completedToday
                              ? AppColors.success
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${q.label} +${q.xpReward}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: q.completedToday
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),
                      ]),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCheckin,
              child: const Text('Check-in quotidien'),
            ),
          ),
        ],
      ),
    );
  }
}
