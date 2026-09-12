import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// Reusable animation utilities for RuachEdu.
/// All animations respect reduced-motion settings.

bool _reduceMotion(BuildContext context) {
  return MediaQuery.of(context).accessibleNavigation;
}

/// Staggered fade-in + slide-up builder for list items.
///
/// [key] doit être le même que celui du [child] quand cet item vit dans une
/// liste dont le contenu peut changer de forme entre deux rebuilds (ex.
/// squelette de chargement -> données réelles) : sans clé partagée,
/// l'enveloppe (`_StaggerItem`) et son enfant peuvent se faire réassocier
/// incorrectement lors de la réconciliation de la sliver list.
Widget staggerItem({Key? key, required int index, required Widget child, Duration? baseDelay}) {
  return _StaggerItem(key: key, index: index, baseDelay: baseDelay ?? RuachMotion.staggerDelay, child: child);
}

class _StaggerItem extends StatefulWidget {
  const _StaggerItem({super.key, required this.index, required this.child, required this.baseDelay});
  final int index;
  final Widget child;
  final Duration baseDelay;
  @override
  State<_StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<_StaggerItem> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    // Duree par defaut ; ajustee dans didChangeDependencies une fois
    // MediaQuery lisible en toute securite (voir plus bas).
    _ctrl = AnimationController(vsync: this, duration: RuachMotion.appear);
    _opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: RuachCurves.appear),
    );
    _slide = Tween(begin: const Offset(0, 12), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: RuachCurves.appear),
    );
    Future.delayed(widget.baseDelay * widget.index, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery.of(context) est interdit dans initState (l'Element n'est
    // pas encore monte) -- l'appeler la-bas pouvait laisser le montage d'un
    // item de liste inachieve et corrompre l'arbre de la sliver list au
    // rebuild suivant (cascade "Duplicate GlobalKey" / "child == _child").
    // didChangeDependencies est le point sur, avant le premier frame peint.
    if (_reduceMotion(context)) _ctrl.duration = Duration.zero;
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, c) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(offset: _slide.value, child: c),
      ),
      child: widget.child,
    );
  }
}

/// Wraps a list of widgets with staggered fade-in.
List<Widget> staggerList(List<Widget> children, {Duration? baseDelay}) {
  return children.asMap().entries.map((e) =>
    staggerItem(index: e.key, child: e.value, baseDelay: baseDelay),
  ).toList();
}
