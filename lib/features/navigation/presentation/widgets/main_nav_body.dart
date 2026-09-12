import 'package:eduquest/features/assistant/presentation/ai_assistant_page.dart';
import 'package:eduquest/features/engagement/presentation/engagement_hub_page.dart';
import 'package:eduquest/features/home/presentation/home_page.dart';
import 'package:eduquest/features/learning/presentation/learning_page.dart';
import 'package:eduquest/features/profile/presentation/profile_page.dart';
import 'package:eduquest/features/navigation/presentation/widgets/lazy_tab_stack.dart';
import 'package:flutter/material.dart';

/// Lazily keeps tabs alive after first opening them.
class MainNavBody extends StatelessWidget {
  const MainNavBody({
    super.key,
    required this.index,
    required this.scopeRev,
    required this.onThemeToggle,
    required this.themeMode,
    this.tabBuilders,
  });
  final int index;
  final int scopeRev;
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  final List<WidgetBuilder>? tabBuilders;

  @override
  Widget build(BuildContext context) {
    final builders =
        tabBuilders ??
        [
          (_) => HomePage(onThemeToggle: onThemeToggle, themeMode: themeMode),
          (_) => AiAssistantPage(key: ValueKey('assistant-$scopeRev')),
          // La protection capture d'écran vit sur les écrans de contenu
          // (visionneuse PDF/vidéo, quiz, épreuve), pas sur l'onglet Apprendre
          // ni ses listes/menus — voir SensitiveScope sur ces écrans.
          (_) => LearningPage(key: ValueKey('learn-$scopeRev')),
          (_) => EngagementHubPage(key: ValueKey('hub-$scopeRev')),
          (_) => ProfilePage(
                onThemeToggle: onThemeToggle,
                themeMode: themeMode,
              ),
        ];
    return LazyTabStack(
      index: index,
      builders: builders,
    );
  }
}
