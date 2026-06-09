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
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(RuachRadius.md)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(RuachSpace.s4),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField(
              initialValue: level,
              items: levels.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => onLevelChanged('$v'),
              decoration: _dec(),
            ),
          ),
          const SizedBox(width: RuachSpace.s2),
          Expanded(
            child: DropdownButtonFormField(
              initialValue: serie,
              items: series.map((v) => DropdownMenuItem(value: v, child: Text('Serie $v'))).toList(),
              onChanged: (v) => onSerieChanged('$v'),
              decoration: _dec(),
            ),
          ),
        ],
      ),
    );
  }
}
