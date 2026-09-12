import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class HomeBodyShimmer extends StatefulWidget {
  const HomeBodyShimmer({super.key});
  @override
  State<HomeBodyShimmer> createState() => _HomeBodyShimmerState();
}

class _HomeBodyShimmerState extends State<HomeBodyShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }
  Widget _box({required double h, double? w}) =>
      _ShimmerLine(progress: _c, height: h, width: w);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _box(h: 26, w: 170),
        const SizedBox(height: 8),
        _box(h: 14, w: 210),
        const SizedBox(height: 16),
        _box(h: 96),
        const SizedBox(height: 12),
        _box(h: 130),
        const SizedBox(height: 12),
        _box(h: 64),
      ],
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({
    required this.progress,
    required this.height,
    this.width,
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
                  builder: (_, __) => Transform.translate(
                    offset: Offset((w * 1.7 * progress.value) - (w * .8), 0),
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
