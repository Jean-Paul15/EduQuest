import 'package:eduquest/features/class_selection/data/class_selection_repository.dart';
import 'package:eduquest/features/class_selection/domain/level_option.dart';
import 'package:eduquest/features/class_selection/domain/series_option.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:flutter/material.dart';

class ClassSelectionPanel extends StatefulWidget {
  const ClassSelectionPanel({super.key, this.onChanged});
  final VoidCallback? onChanged;
  @override
  State<ClassSelectionPanel> createState() => _ClassSelectionPanelState();
}

class _ClassSelectionPanelState extends State<ClassSelectionPanel> {
  final _repo = ClassSelectionRepository();
  List<LevelOption> _levels = const [];
  List<SeriesOption> _series = const [];
  String? _levelId, _seriesId;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final levels = await _repo.activeLevels();
    final cur = await _repo.current();
    final levelId = levels.any((e) => e.id == cur['levelId'])
        ? cur['levelId']
        : (levels.isEmpty ? null : levels.first.id);
    final series = levelId == null
        ? const <SeriesOption>[]
        : await _repo.activeSeries(levelId);
    final seriesId = series.any((e) => e.id == cur['seriesId'])
        ? cur['seriesId']
        : (series.isEmpty ? null : series.first.id);
    if (!mounted) return;
    setState(() {
      _levels = levels;
      _levelId = levelId;
      _series = series;
      _seriesId = seriesId;
    });
  }

  Future<void> _onLevelTap(String v) async {
    final s = await _repo.activeSeries(v);
    if (!mounted) return;
    setState(() {
      _levelId = v;
      _series = s;
      _seriesId = s.isEmpty ? null : s.first.id;
    });
  }

  Future<void> _save() async {
    if (_levelId == null || _busy) return;
    setState(() => _busy = true);
    final msg = await _repo.change(_levelId!, _seriesId);
    if (!mounted) return;
    setState(() => _busy = false);
    final ok =
        !msg.toLowerCase().contains('invalide') &&
        !msg.toLowerCase().contains('non');
    ModernSnackbar.show(context, msg, success: ok);
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_levels.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppSpace.m),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Classe et serie',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpace.s),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _levels
                .map(
                  (e) => ChoiceChip(
                    label: Text(
                      e.label,
                      style: TextStyle(
                        color: e.id == _levelId
                            ? AppColors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: e.id == _levelId,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceCard,
                    side: BorderSide(
                      color: e.id == _levelId
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                    onSelected: (_) => _onLevelTap(e.id),
                  ),
                )
                .toList(),
          ),
          if (_series.isNotEmpty) ...[
            const SizedBox(height: AppSpace.s),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _series
                  .map(
                    (e) => ChoiceChip(
                      label: Text(
                        e.label,
                        style: TextStyle(
                          color: e.id == _seriesId
                              ? AppColors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: e.id == _seriesId,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceCard,
                      side: BorderSide(
                        color: e.id == _seriesId
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                      onSelected: (_) => setState(() => _seriesId = e.id),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpace.m),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _busy ? null : _save,
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: Text(_busy ? 'Mise a jour...' : 'Appliquer'),
            ),
          ),
        ],
      ),
    );
  }
}
