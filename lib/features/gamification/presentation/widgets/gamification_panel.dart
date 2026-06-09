import 'package:eduquest/features/gamification/domain/daily_quest.dart';
import 'package:eduquest/features/gamification/domain/gamification_state.dart';
import 'package:eduquest/features/gamification/presentation/widgets/quest_badge.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/glass_container.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Niv. ${state.level}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: RuachColors.cream900,
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
            ],
          ),
          const SizedBox(height: RuachSpace.s2),
          RuachProgressBar(value: state.levelProgress),
          const SizedBox(height: RuachSpace.s3),
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.fire,
                size: 16,
                color: RuachColors.gold600,
              ),
              const SizedBox(width: RuachSpace.s1),
              Text(
                '${state.streakDays}j',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: RuachColors.cream900,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Record: ${state.bestStreak}j',
                style: const TextStyle(
                  color: RuachColors.cream500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (quests.isNotEmpty) ...[
            const SizedBox(height: RuachSpace.s3),
            Wrap(
              spacing: RuachSpace.s2,
              runSpacing: RuachSpace.s2,
              children: quests.map((q) => QuestBadge(quest: q)).toList(),
            ),
          ],
          const SizedBox(height: 12),
          RuachButton(
            label: 'Check-in quotidien',
            onPressed: onCheckin,
          ),
        ],
      ),
    );
  }
}
