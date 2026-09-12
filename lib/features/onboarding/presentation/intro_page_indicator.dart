import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class IntroPageIndicator extends StatelessWidget {
  const IntroPageIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    required this.primaryColor,
  });

  final int itemCount;
  final int currentIndex;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        itemCount,
        (i) => AnimatedContainer(
          duration: RuachMotion.appear,
          width: i == currentIndex ? 24 : 6,
          height: 6,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: i == currentIndex
                ? primaryColor
                : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: .3),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
