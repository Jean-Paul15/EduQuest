import 'package:eduquest/features/navigation/presentation/widgets/nav_badge_icon.dart';
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
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          NavigationDestination(icon: Semantics(label: 'Accueil', child: const Icon(PhosphorIconsRegular.house)), selectedIcon: Semantics(label: 'Accueil', child: const Icon(PhosphorIconsFill.house)), label: 'Accueil'),
          NavigationDestination(icon: Semantics(label: 'Assistant RuachEdu', child: const Icon(PhosphorIconsRegular.chatCircleDots)), selectedIcon: Semantics(label: 'Assistant RuachEdu', child: const Icon(PhosphorIconsFill.chatCircleDots)), label: 'Assistant'),
          NavigationDestination(icon: Semantics(label: 'Apprendre', child: const Icon(PhosphorIconsRegular.books)), selectedIcon: Semantics(label: 'Apprendre', child: const Icon(PhosphorIconsFill.books)), label: 'Apprendre'),
          NavigationDestination(icon: Semantics(label: 'Hub', child: NavBadgeIcon(icon: PhosphorIconsRegular.squaresFour, count: hubBadge)), selectedIcon: Semantics(label: 'Hub', child: NavBadgeIcon(icon: PhosphorIconsFill.squaresFour, count: hubBadge)), label: 'Hub'),
          NavigationDestination(icon: Semantics(label: 'Profil', child: const Icon(PhosphorIconsRegular.user)), selectedIcon: Semantics(label: 'Profil', child: const Icon(PhosphorIconsFill.user)), label: 'Profil'),
        ],
      ),
    );
  }
}
