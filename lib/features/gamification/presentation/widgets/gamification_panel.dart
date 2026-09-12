import 'package:eduquest/features/gamification/domain/daily_quest.dart';
import 'package:eduquest/features/gamification/domain/gamification_state.dart';
import 'package:eduquest/features/gamification/presentation/widgets/quest_badge.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/glass_container.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class GamificationPanel extends StatefulWidget {
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
  State<GamificationPanel> createState() => _GamificationPanelState();
}

class _GamificationPanelState extends State<GamificationPanel> {
  bool _checkingIn = false;

  Future<void> _handleCheckin() async {
    if (_checkingIn) return;
    setState(() => _checkingIn = true);
    try {
      await widget.onCheckin();
    } finally {
      if (mounted) setState(() => _checkingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final state = widget.state;
    final quests = widget.quests;
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: RuachSpace.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Niv. ${state.level}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: s.onSurface,
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
          const SizedBox(height: RuachSpace.s3),
          RuachProgressBar(value: state.levelProgress),
          const SizedBox(height: RuachSpace.s4),
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.fire,
                size: 20,
                color: RuachColors.gold600,
              ),
              const SizedBox(width: RuachSpace.s1),
              Text(
                '${state.streakDays}j',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: s.onSurface,
                ),
              ),
              const SizedBox(width: RuachSpace.s3),
              Text(
                'Record: ${state.bestStreak}j',
                style: TextStyle(
                  color: s.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (quests.isNotEmpty) ...[
            const SizedBox(height: RuachSpace.s4),
            Wrap(
              spacing: RuachSpace.s2,
              runSpacing: RuachSpace.s2,
              children: quests.map((q) => QuestBadge(quest: q)).toList(),
            ),
          ],
          const SizedBox(height: RuachSpace.s4),
          RuachButton(
            label: 'Check-in quotidien',
            loading: _checkingIn,
            onPressed: _handleCheckin,
          ),
        ],
      ),
    );
  }
}
