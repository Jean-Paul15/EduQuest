import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class RuachTabBar extends StatelessWidget implements PreferredSizeWidget {
  const RuachTabBar({super.key, required this.tabs, this.isScrollable = true});

  final List<Tab> tabs;
  final bool isScrollable;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerLeft,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: TabBar(
        isScrollable: isScrollable,
        tabAlignment: isScrollable ? TabAlignment.start : null,
        // .label (au lieu de .tab) mesure l'indicateur sur le contenu réellement paddé du Tab
        // (voir le Padding ajouté ci-dessous) plutôt que sur toute la largeur du slot — c'est
        // ce qui évite le pill mal ajusté/déformé selon la longueur du libellé.
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelPadding: const EdgeInsets.symmetric(horizontal: RuachSpace.s1),
        splashBorderRadius: BorderRadius.circular(RuachRadius.full),
        labelColor: RuachColors.white,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicator: BoxDecoration(
          color: RuachColors.gold500,
          borderRadius: BorderRadius.circular(RuachRadius.full),
          boxShadow: RuachShadows.buttonGlow,
        ),
        indicatorPadding: EdgeInsets.zero,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: tabs.map((tab) {
          final content = tab.child ??
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (tab.icon != null) tab.icon!,
                if (tab.icon != null && tab.text != null) const SizedBox(width: RuachSpace.s1),
                if (tab.text != null) Text(tab.text!),
              ]);
          return Tab(
            height: 36,
            // Le padding fait partie du contenu mesuré (indicatorSize: .label) plutôt que du
            // TabBar (labelPadding) : le pill épouse toujours exactement cette boîte, quelle
            // que soit la largeur du libellé/icône/badge.
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: RuachSpace.s4),
              child: content,
            ),
          );
        }).toList(),
      ),
    );
  }
}
