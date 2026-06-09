import 'package:eduquest/features/navigation/presentation/widgets/nav_badge_icon.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Bottom NavigationBar for MainNavPage with 5 destinations.
class MainNavBar extends StatelessWidget {
  const MainNavBar({
    super.key,
    required this.selectedIndex,
    required this.hubBadge,
    required this.onDestinationSelected,
  });
  final int selectedIndex;
  final int hubBadge;
  final void Function(int) onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).navigationBarTheme.backgroundColor,
        border: const Border(top: BorderSide(color: RuachColors.cream200, width: 0.5)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          const NavigationDestination(icon: Icon(PhosphorIconsRegular.house), selectedIcon: Icon(PhosphorIconsFill.house), label: 'Accueil'),
          const NavigationDestination(icon: Icon(PhosphorIconsRegular.compass), selectedIcon: Icon(PhosphorIconsFill.compass), label: 'Feed'),
          const NavigationDestination(icon: Icon(PhosphorIconsRegular.books), selectedIcon: Icon(PhosphorIconsFill.books), label: 'Apprendre'),
          NavigationDestination(icon: NavBadgeIcon(icon: PhosphorIconsRegular.squaresFour, count: hubBadge), selectedIcon: NavBadgeIcon(icon: PhosphorIconsFill.squaresFour, count: hubBadge), label: 'Hub'),
          const NavigationDestination(icon: Icon(PhosphorIconsRegular.user), selectedIcon: Icon(PhosphorIconsFill.user), label: 'Profil'),
        ],
      ),
    );
  }
}
