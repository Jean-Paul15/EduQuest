import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

/// Level + serie filter row for VideosPage.
class VideoFilters extends StatelessWidget {
  const VideoFilters({
    super.key,
    required this.level,
    required this.serie,
    required this.levels,
    required this.series,
    required this.onLevelChanged,
    required this.onSerieChanged,
  });
  final String level;
  final String serie;
  final List<String> levels;
  final List<String> series;
  final void Function(String) onLevelChanged;
  final void Function(String) onSerieChanged;

  static InputDecoration _dec() => InputDecoration(
    isDense: true,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(RuachRadius.md),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: RuachSpace.s3, vertical: RuachSpace.s2),
  );

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(RuachSpace.s4),
      child: Container(
        padding: const EdgeInsets.all(RuachSpace.s3),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: s.outlineVariant),
          borderRadius: BorderRadius.circular(RuachRadius.lg),
        ),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: levels.contains(level) ? level : null,
                items: levels
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) => v == null ? null : onLevelChanged(v),
                decoration: _dec().copyWith(labelText: 'Classe'),
              ),
            ),
            if (series.isNotEmpty) ...[
              const SizedBox(width: RuachSpace.s2),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: series.contains(serie) ? serie : null,
                  items: series
                      .map(
                        (v) =>
                            DropdownMenuItem(value: v, child: Text('Série $v')),
                      )
                      .toList(),
                  onChanged: (v) => v == null ? null : onSerieChanged(v),
                  decoration: _dec().copyWith(labelText: 'Série'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
