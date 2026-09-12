import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/features/gamification/domain/daily_quest.dart';
import 'package:eduquest/features/gamification/domain/gamification_state.dart';
import 'package:eduquest/features/gamification/presentation/widgets/gamification_panel.dart';
import 'package:eduquest/features/home/presentation/widgets/access_banner.dart';
import 'package:eduquest/features/home/presentation/widgets/action_tile.dart';
import 'package:eduquest/features/home/presentation/widgets/motivational_quote.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({
    super.key,
    required this.displayName,
    required this.access,
    required this.gamification,
    required this.quests,
    required this.onCheckin,
    required this.onOpenTicket,
    required this.onBuyTicket,
  });

  final String displayName;
  final AccessState access;
  final GamificationState gamification;
  final List<DailyQuest> quests;
  final Future<void> Function() onCheckin;
  final VoidCallback onOpenTicket;
  final VoidCallback onBuyTicket;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final tx = Theme.of(context).textTheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(RuachSpace.s4, RuachSpace.s4, RuachSpace.s4, RuachSpace.s6),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salut, $displayName',
                    style: tx.headlineMedium,
                  ),
                  const SizedBox(height: RuachSpace.s1),
                  Text(
                    'Continue ta progression.',
                    style: tx.bodyMedium?.copyWith(color: s.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(RuachSpace.s2),
              decoration: BoxDecoration(
                color: s.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(RuachRadius.md),
              ),
              child: Icon(
                PhosphorIconsRegular.fire,
                color: s.primary,
                size: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: RuachSpace.s8),
        AccessBanner(access: access),
        const SizedBox(height: RuachSpace.s6),
        GamificationPanel(
          state: gamification,
          quests: quests,
          onCheckin: onCheckin,
        ),
        const SizedBox(height: RuachSpace.s8),
        ActionTile(
          title: 'Activer un ticket',
          subtitle: 'Active ton code ou achète ton ticket sur le site',
          icon: PhosphorIconsRegular.ticket,
          onTap: onOpenTicket,
          actionLabel: 'Acheter',
          actionIcon: PhosphorIconsRegular.shoppingCart,
          onAction: onBuyTicket,
        ),
        const SizedBox(height: RuachSpace.s10),
        const MotivationalQuote(),
      ],
    );
  }
}
