import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class LoadingShimmerPage extends StatefulWidget {
  const LoadingShimmerPage({super.key});
  @override
  State<LoadingShimmerPage> createState() => _LoadingShimmerPageState();
}

class _LoadingShimmerPageState extends State<LoadingShimmerPage>
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
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RuachSpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerStrip(progress: _c, height: 28, width: 180),
              const SizedBox(height: 10),
              _ShimmerStrip(progress: _c, height: 14, width: 240),
              const SizedBox(height: 24),
              _ShimmerStrip(progress: _c, height: 96),
              const SizedBox(height: 14),
              _ShimmerStrip(progress: _c, height: 130),
              const SizedBox(height: 14),
              _ShimmerStrip(progress: _c, height: 64),
              const SizedBox(height: 14),
              _ShimmerStrip(progress: _c, height: 64),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerStrip extends StatelessWidget {
  const _ShimmerStrip({
    required this.progress,
    required this.height,
    this.width,
  });
  final Animation<double> progress;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final base = RuachColors.cream200.withValues(alpha: .65);
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
