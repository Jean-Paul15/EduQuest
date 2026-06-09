import 'package:eduquest/features/engagement/presentation/engagement_hub_page.dart';
import 'package:eduquest/features/feed/presentation/feed_page.dart';
import 'package:eduquest/features/home/presentation/home_page.dart';
import 'package:eduquest/features/learning/presentation/learning_page.dart';
import 'package:eduquest/features/profile/presentation/profile_page.dart';
import 'package:flutter/material.dart';

/// IndexedStack body for MainNavPage — 5 tabs always alive.
class MainNavBody extends StatelessWidget {
  const MainNavBody({
    super.key,
    required this.index,
    required this.scopeRev,
    required this.onThemeToggle,
    required this.themeMode,
  });
  final int index;
  final int scopeRev;
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: index,
      children: [
        HomePage(onThemeToggle: onThemeToggle, themeMode: themeMode),
        FeedPage(key: ValueKey('feed-$scopeRev')),
        LearningPage(key: ValueKey('learn-$scopeRev')),
        EngagementHubPage(key: ValueKey('hub-$scopeRev')),
        ProfilePage(onThemeToggle: onThemeToggle, themeMode: themeMode),
      ],
    );
  }
}
