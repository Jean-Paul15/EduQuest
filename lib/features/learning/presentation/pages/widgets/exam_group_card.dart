import 'package:eduquest/features/learning/domain/exam_entry.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// A grouped ExpansionTile card for a semester's exam entries.
class ExamGroupCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: RuachSpace.s2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: RuachColors.cream200),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: ExpansionTile(
        title: Text(
          'Semestre: $semester',
          style: const TextStyle(fontWeight: FontWeight.w600, color: RuachColors.cream900),
        ),
        children: entries
            .map(
              (e) => ListTile(
                title: Text(e.title, style: const TextStyle(color: RuachColors.cream900)),
                subtitle: Text(
                  e.correctionUrl?.isNotEmpty == true ? 'Avec correction' : 'Sans correction',
                  style: const TextStyle(fontSize: 12, color: RuachColors.cream700),
                ),
                trailing: const Icon(PhosphorIconsRegular.caretRight, color: RuachColors.cream700),
                onTap: () => onEntryTap(e),
              ),
            )
            .toList(),
      ),
    );
  }
}
