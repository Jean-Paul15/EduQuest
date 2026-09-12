import 'package:eduquest/features/learning/domain/exam_entry.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ExamGroupCard extends StatefulWidget {
  const ExamGroupCard({
    super.key,
    required this.semester,
    required this.entries,
    required this.onEntryTap,
  });
  final String semester;
  final List<ExamEntry> entries;
  final void Function(ExamEntry entry) onEntryTap;

  @override
  State<ExamGroupCard> createState() => _ExamGroupCardState();
}

class _ExamGroupCardState extends State<ExamGroupCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: RuachSpace.s2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: s.outlineVariant),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(RuachRadius.lg),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(RuachSpace.s3),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: RuachColors.gold500.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(RuachRadius.md),
                  ),
                  child: const Icon(
                    PhosphorIconsRegular.calendarBlank,
                    size: 16,
                    color: RuachColors.gold500,
                  ),
                ),
                const SizedBox(width: RuachSpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.semester,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: s.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.entries.length} document(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: s.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? .5 : .25,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    PhosphorIconsRegular.caretDown,
                    color: s.onSurfaceVariant,
                  ),
                ),
              ]),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: widget.entries
                  .map((e) => _entryCard(context, e, s))
                  .toList(),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _entryCard(BuildContext context, ExamEntry entry, ColorScheme s) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: TapScale(
          onTap: () => widget.onEntryTap(entry),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(RuachRadius.md),
              onTap: () => widget.onEntryTap(entry),
              child: Container(
                padding: const EdgeInsets.all(RuachSpace.s3),
                decoration: BoxDecoration(
                  color: s.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(RuachRadius.md),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: s.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.correctionUrl?.isNotEmpty == true
                              ? 'Sujet + correction disponible'
                              : 'Sujet disponible',
                          style: TextStyle(
                            fontSize: 12,
                            color: s.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: RuachSpace.s2),
                  Icon(
                    PhosphorIconsRegular.caretRight,
                    color: s.onSurfaceVariant,
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
}
