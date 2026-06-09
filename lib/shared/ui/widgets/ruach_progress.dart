import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Linear progress bar — 6dp height, gold gradient fill.
class RuachProgressBar extends StatelessWidget {
  const RuachProgressBar({super.key, required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(RuachRadius.full),
      child: SizedBox(
        height: 6,
        width: double.infinity,
        child: Stack(
          children: [
            Container(color: isDark ? RuachColors.ink500 : RuachColors.cream200),
            FractionallySizedBox(
              widthFactor: value.clamp(0, 1),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [RuachColors.gold400, RuachColors.gold600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular progress indicator — 64dp diameter, gold stroke.
class RuachCircularProgress extends StatelessWidget {
  const RuachCircularProgress({super.key, required this.value, required this.label});
  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 64, height: 64,
            child: CircularProgressIndicator(
              value: value.clamp(0, 1),
              strokeWidth: 6,
              backgroundColor: RuachColors.ink500,
              color: RuachColors.gold500,
            ),
          ),
          Text(label, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: RuachColors.gold400)),
        ],
      ),
    );
  }
}

/// Streak indicator — 7 circles of 32dp, gold for completed.
class RuachStreak extends StatelessWidget {
  const RuachStreak({super.key, required this.days});
  final List<bool> days; // 7 entries, true = completed

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (i) {
        final done = i < days.length && days[i];
        final today = i == days.length - 1;
        return Container(
          width: 32, height: 32,
          margin: const EdgeInsets.symmetric(horizontal: RuachSpace.s1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? RuachColors.streakGold : RuachColors.ink500,
            border: today && !done ? Border.all(color: RuachColors.streakGold, width: 2) : null,
          ),
          alignment: Alignment.center,
          child: done ? const Icon(PhosphorIconsRegular.fire, color: RuachColors.white, size: 16) : Text('${i + 1}', style: const TextStyle(color: RuachColors.cream500, fontSize: 11)),
        );
      }),
    );
  }
}
