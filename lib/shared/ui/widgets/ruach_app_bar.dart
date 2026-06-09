import 'package:flutter/material.dart';

/// Custom app bar — 56dp, transparent bg, scroll-aware shadow via SliverAppBar.
class RuachAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RuachAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
  });
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      automaticallyImplyLeading: showBack,
      actions: actions,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
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
    return SliverAppBar(
      title: Text(title),
      centerTitle: true,
      pinned: pinned,
      floating: false,
      actions: actions,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
    );
  }
}
