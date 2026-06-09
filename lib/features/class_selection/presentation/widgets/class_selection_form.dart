import 'package:eduquest/features/class_selection/domain/level_option.dart';
import 'package:eduquest/features/class_selection/domain/series_option.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_chip.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// The level/series chip panel + apply button for ClassSelectionPanel.
class ClassSelectionForm extends StatelessWidget {
  const ClassSelectionForm({
    super.key,
    required this.levels,
    required this.levelId,
    required this.series,
    required this.seriesId,
    required this.busy,
    required this.onLevelTap,
    required this.onSeriesSelected,
    required this.onSave,
  });
  final List<LevelOption> levels;
  final String? levelId;
  final List<SeriesOption> series;
  final String? seriesId;
  final bool busy;
  final void Function(String) onLevelTap;
  final void Function(SeriesOption) onSeriesSelected;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: RuachColors.cream200),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Classe et serie', style: TextStyle(fontWeight: FontWeight.w700, color: RuachColors.cream900)),
          const SizedBox(height: RuachSpace.s2),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: levels.map((e) => RuachChip(label: e.label, selected: e.id == levelId, onTap: () => onLevelTap(e.id))).toList(),
          ),
          if (series.isNotEmpty) ...[
            const SizedBox(height: RuachSpace.s2),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: series.map((e) => RuachChip(
                label: e.label,
                selected: e.id == seriesId,
                onTap: () => onSeriesSelected(e),
              )).toList(),
            ),
          ],
          const SizedBox(height: RuachSpace.s3),
          Align(
            alignment: Alignment.centerRight,
            child: RuachButton(
              label: busy ? 'Mise a jour...' : 'Appliquer',
              onPressed: busy ? null : onSave,
              icon: PhosphorIconsRegular.checkCircle,
            ),
          ),
        ],
      ),
    );
  }
}
