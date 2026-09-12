import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class QuizListItem extends StatelessWidget {
  const QuizListItem({
    super.key,
    required this.quiz,
    required this.onTap,
    this.hasSavedProgress = false,
    this.isOfflineReady = false,
    this.lastResult,
  });
  final QuizSummary quiz;
  final VoidCallback onTap;
  final bool hasSavedProgress;
  final bool isOfflineReady;
  final ({int scorePercent, bool passed})? lastResult;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: quiz.title,
      child: TapScale(
        onTap: onTap,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(RuachRadius.lg),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(RuachSpace.s3),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(
                  color: hasSavedProgress
                      ? s.primary.withValues(alpha: .28)
                      : s.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(RuachRadius.lg),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: RuachColors.gold500.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(RuachRadius.md),
                    ),
                    child: const Icon(
                      PhosphorIconsRegular.puzzlePiece,
                      size: 18,
                      color: RuachColors.gold500,
                    ),
                  ),
                  const SizedBox(width: RuachSpace.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          quiz.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: s.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatusPill(
                              label: hasSavedProgress ? 'Reprendre' : 'Nouveau',
                              icon: hasSavedProgress
                                  ? PhosphorIconsRegular.playCircle
                                  : PhosphorIconsRegular.sparkle,
                              background: hasSavedProgress
                                  ? s.primary.withValues(alpha: .12)
                                  : s.surfaceContainerHighest,
                              foreground: hasSavedProgress
                                  ? s.primary
                                  : s.onSurfaceVariant,
                            ),
                            if (isOfflineReady)
                              _StatusPill(
                                label: 'Hors ligne',
                                icon: PhosphorIconsRegular.downloadSimple,
                                background: RuachColors.gold500.withValues(
                                  alpha: .12,
                                ),
                                foreground: RuachColors.gold500,
                              ),
                            if (lastResult != null)
                              _StatusPill(
                                label: '${lastResult!.scorePercent} %',
                                icon: lastResult!.passed
                                    ? PhosphorIconsRegular.checkCircle
                                    : PhosphorIconsRegular.arrowClockwise,
                                background: lastResult!.passed
                                    ? RuachColors.success600.withValues(alpha: .12)
                                    : RuachColors.warning400.withValues(alpha: .16),
                                foreground: lastResult!.passed
                                    ? RuachColors.success600
                                    : RuachColors.warning400,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: RuachSpace.s2),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasSavedProgress
                          ? s.primary.withValues(alpha: .10)
                          : s.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(RuachRadius.full),
                    ),
                    child: Icon(
                      hasSavedProgress
                          ? PhosphorIconsRegular.playCircle
                          : PhosphorIconsRegular.caretRight,
                      color: hasSavedProgress ? s.primary : s.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(RuachRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
