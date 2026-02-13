import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/features/gamification/domain/daily_quest.dart';
import 'package:eduquest/features/gamification/domain/gamification_state.dart';
import 'package:eduquest/features/gamification/presentation/widgets/gamification_panel.dart';
import 'package:eduquest/features/home/presentation/widgets/access_banner.dart';
import 'package:eduquest/features/home/presentation/widgets/action_tile.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salut, $displayName',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Continue ta progression.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: s.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
              child: Icon(
                Icons.local_fire_department_rounded,
                color: s.primary,
                size: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AccessBanner(access: access),
        const SizedBox(height: 12),
        GamificationPanel(
          state: gamification,
          quests: quests,
          onCheckin: onCheckin,
        ),
        ActionTile(
          title: 'Activer un ticket',
          subtitle: 'Active ton code ou achete ton ticket sur le site',
          icon: Icons.confirmation_number_outlined,
          onTap: onOpenTicket,
          actionLabel: 'Acheter',
          actionIcon: Icons.shopping_cart_checkout_rounded,
          onAction: onBuyTicket,
        ),
      ],
    );
  }
}
