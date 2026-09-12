import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// Custom app bar — 56dp, transparent bg, scroll-aware shadow via SliverAppBar.
class RuachAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RuachAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
    this.leading,
    this.bottom,
  });
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(60 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? RuachColors.ink200 : RuachColors.cream50;
    return AppBar(
      toolbarHeight: 64,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
      ),
      titleSpacing: leading == null && !showBack ? RuachSpace.s5 : 0,
      centerTitle: false,
      automaticallyImplyLeading: showBack,
      leading: leading,
      actions: actions,
      elevation: 0,
      scrolledUnderElevation: 6,
      shadowColor: RuachColors.black.withValues(alpha: .18),
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bg,
              dark
                  ? RuachColors.ink200.withValues(alpha: .96)
                  : RuachColors.cream100.withValues(alpha: .96),
            ],
          ),
        ),
      ),
      shape: Border(
        bottom: BorderSide(
          color: RuachColors.gold500.withValues(alpha: dark ? .32 : .22),
        ),
      ),
      bottom: bottom,
    );
  }
}

/// Scroll-aware sliver app bar — adds shadow on scroll.
class RuachSliverAppBar extends StatelessWidget {
  const RuachSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.pinned = true,
  });
  final String title;
  final List<Widget>? actions;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      toolbarHeight: 60,
      title: Text(title),
      centerTitle: false,
      pinned: pinned,
      floating: false,
      actions: actions,
      elevation: 0,
      scrolledUnderElevation: 3,
      shadowColor: RuachColors.black.withValues(alpha: .18),
      backgroundColor: dark ? RuachColors.ink200 : RuachColors.cream50,
      surfaceTintColor: Colors.transparent,
      shape: Border(
        bottom: BorderSide(
          color: RuachColors.gold500.withValues(alpha: dark ? .32 : .22),
        ),
      ),
    );
  }
}
