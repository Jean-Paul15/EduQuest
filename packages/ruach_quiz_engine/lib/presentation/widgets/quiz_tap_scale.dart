import 'package:flutter/material.dart';
import '../tokens.dart';

/// Copie de lib/shared/ui/widgets/ruach_tap_scale.dart (le package ne peut pas
/// dépendre de l'app hôte) — animation d'échelle au tap (0.96, 100ms easeOut),
/// désactivée automatiquement si l'utilisateur a demandé de réduire les
/// animations système.
bool _reduceMotion(BuildContext context) => MediaQuery.of(context).accessibleNavigation;

class QuizTapScale extends StatefulWidget {
  const QuizTapScale({super.key, required this.child, this.onTap, this.scale = 0.96});
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  @override
  State<QuizTapScale> createState() => _QuizTapScaleState();
}

class _QuizTapScaleState extends State<QuizTapScale> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _reduce = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: QuizMotion.tap);
    _anim = Tween(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _ctrl, curve: QuizCurves.tap),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _down(_) { _reduce = _reduceMotion(context) == true; if (!_reduce) _ctrl.forward(); }
  // Le callback se declenche immediatement au relachement -- ne jamais le
  // faire attendre la fin de l'animation de retour (`.then(...)`), qui
  // pouvait le faire manquer si un rebuild (ex. selection d'une case juste
  // avant) survenait pendant la fenetre d'attente de l'animation.
  void _up(_) {
    if (!_reduce) _ctrl.reverse();
    widget.onTap?.call();
  }
  void _cancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down, onTapUp: _up, onTapCancel: _cancel,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, c) => Transform.scale(scale: _anim.value, child: c),
        child: widget.child,
      ),
    );
  }
}
