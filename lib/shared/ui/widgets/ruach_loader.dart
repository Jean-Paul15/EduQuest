import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_loader_painter.dart';
import 'package:flutter/material.dart';

/// Indicateur de chargement anime : un atome vivant (voir [AtomLoaderPainter]).
/// Respecte `MediaQuery.disableAnimations` : hors mouvement reduit l'animation
/// tourne en continu, sinon l'atome reste fige.
///
/// A adapter a l'ecran : [period] court (defaut ~1 s) pour un chargement bref
/// ou l'atome doit avoir bouge visiblement avant de disparaitre ; [period] plus
/// long pour un ecran d'attente qui dure, ou un rythme trop rapide fatiguerait.
class RuachLoader extends StatefulWidget {
  const RuachLoader({
    super.key,
    this.label,
    this.size = 112,
    this.period = const Duration(milliseconds: 1050),
  });

  final String? label;
  final double size;
  final Duration period;

  @override
  State<RuachLoader> createState() => _RuachLoaderState();
}

class _RuachLoaderState extends State<RuachLoader>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce == _reduceMotion) return;
    _reduceMotion = reduce;
    if (reduce) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: widget.label ?? 'Chargement en cours',
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: widget.size,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) => CustomPaint(
                  painter: AtomLoaderPainter(
                    t: _controller.value,
                    dark: dark,
                    reduceMotion: _reduceMotion,
                  ),
                ),
              ),
            ),
          ),
          if (widget.label case final label?) ...[
            const SizedBox(height: RuachSpace.s3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
