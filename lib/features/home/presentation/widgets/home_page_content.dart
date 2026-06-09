import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/features/gamification/domain/daily_quest.dart';
import 'package:eduquest/features/gamification/domain/gamification_state.dart';
import 'package:eduquest/features/home/presentation/widgets/home_body.dart';
import 'package:eduquest/features/home/presentation/widgets/home_body_shimmer.dart';
import 'package:flutter/material.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({
    super.key,
    required this.displayName,
    required this.access,
    required this.gamification,
    required this.quests,
    required this.loadingHome,
    required this.onRefresh,
    required this.onCheckin,
    required this.onBuyTicket,
    required this.onOpenTicket,
  });

  final String displayName;
  final AccessState access;
  final GamificationState gamification;
  final List<DailyQuest> quests;
  final bool loadingHome;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onCheckin;
  final VoidCallback onBuyTicket;
  final VoidCallback onOpenTicket;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        child: Stack(
          children: [
            HomeBody(
              displayName: displayName,
              access: access,
              gamification: gamification,
              quests: quests,
              onCheckin: onCheckin,
              onBuyTicket: onBuyTicket,
              onOpenTicket: onOpenTicket,
            ),
            if (loadingHome)
              const IgnorePointer(child: HomeBodyShimmer()),
          ],
        ),
      );
}
