import 'package:eduquest/features/class_selection/domain/level_option.dart';
import 'package:eduquest/features/class_selection/domain/series_option.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Level/series dropdown selector + apply button.
/// Data comes from Supabase via ClassSelectionRepository.
class ClassSelectionForm extends StatelessWidget {
  const ClassSelectionForm({
    super.key,
    required this.levels,
    required this.levelId,
    required this.series,
    required this.seriesId,
    required this.busy,
    required this.onLevelChanged,
    required this.onSeriesChanged,
    required this.onSave,
    this.showApplyButton = true,
    this.showSectionTitle = true,
  });
  final List<LevelOption> levels;
  final String? levelId;
  final List<SeriesOption> series;
  final String? seriesId;
  final bool busy;
  final void Function(String) onLevelChanged;
  final void Function(SeriesOption) onSeriesChanged;
  final VoidCallback onSave;
  final bool showApplyButton;
  final bool showSectionTitle;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: s.outlineVariant),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSectionTitle) ...[
            Text(
              'Classe et série',
              style: TextStyle(fontWeight: FontWeight.w700, color: s.onSurface),
            ),
            const SizedBox(height: RuachSpace.s3),
          ],
          DropdownButtonFormField<String>(
            key: ValueKey('level_$levelId'),
            initialValue: levelId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Niveau',
              prefixIcon: const Icon(
                PhosphorIconsRegular.graduationCap,
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RuachRadius.md),
              ),
            ),
            items: levels.map((e) {
              return DropdownMenuItem<String>(
                value: e.id,
                child: Text(e.label, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) onLevelChanged(v);
            },
          ),
          if (series.isNotEmpty) ...[
            const SizedBox(height: RuachSpace.s3),
            DropdownButtonFormField<String>(
              key: ValueKey('series_$seriesId'),
              initialValue: seriesId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Série',
                prefixIcon: const Icon(PhosphorIconsRegular.books, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RuachRadius.md),
                ),
              ),
              items: series.map((e) {
                return DropdownMenuItem<String>(
                  value: e.id,
                  child: Text(e.label, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) {
                  final found = series.where((e) => e.id == v).firstOrNull;
                  if (found != null) onSeriesChanged(found);
                }
              },
            ),
          ],
          if (showApplyButton) ...[
            const SizedBox(height: RuachSpace.s3),
            Align(
              alignment: Alignment.centerRight,
              child: RuachButton(
                label: 'Appliquer',
                loading: busy,
                onPressed: onSave,
                icon: PhosphorIconsRegular.checkCircle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
