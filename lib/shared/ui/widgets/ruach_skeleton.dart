import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton shimmer loader — gradient ink-400 to ink-500 loop.
class RuachSkeleton extends StatelessWidget {
  const RuachSkeleton({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: RuachColors.ink400,
      highlightColor: RuachColors.ink500,
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
    return RuachSkeleton(
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: RuachColors.ink400,
          borderRadius: BorderRadius.circular(RuachRadius.lg),
        ),
      ),
    );
  }
}
