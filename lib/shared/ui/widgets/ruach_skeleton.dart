import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton shimmer loader — adapts to dark/light mode.
class RuachSkeleton extends StatelessWidget {
  const RuachSkeleton({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? RuachColors.ink400 : RuachColors.cream200,
      highlightColor: isDark ? RuachColors.ink500 : RuachColors.cream100,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

/// Convenience skeleton for a course card placeholder.
class RuachCardSkeleton extends StatelessWidget {
  const RuachCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RuachSkeleton(
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: isDark ? RuachColors.ink400 : RuachColors.cream200,
          borderRadius: BorderRadius.circular(RuachRadius.lg),
        ),
      ),
    );
  }
}
