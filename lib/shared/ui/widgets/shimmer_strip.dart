import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class ShimmerStrip extends StatelessWidget {
  const ShimmerStrip({
    required this.progress,
    required this.height,
    this.width,
    super.key,
  });
  final Animation<double> progress;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .65);
    return LayoutBuilder(
      builder: (_, c) {
        final w = width ?? c.maxWidth;
        return SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(RuachRadius.md),
            child: Stack(
              children: [
                Container(color: base),
                AnimatedBuilder(
                  animation: progress,
                  builder: (_, __) {
                    final dx = (w * 1.7 * progress.value) - (w * .8);
                    return Transform.translate(
                      offset: Offset(dx, 0),
                      child: Container(
                        width: w * .55,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white.withValues(alpha: .55),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
