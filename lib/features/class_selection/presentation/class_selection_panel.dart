import 'package:eduquest/features/class_selection/data/class_selection_repository.dart';
import 'package:eduquest/features/class_selection/domain/level_option.dart';
import 'package:eduquest/features/class_selection/domain/series_option.dart';
import 'package:eduquest/features/class_selection/presentation/widgets/class_selection_form.dart';
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
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final levels = await _repo.activeLevels();
    final cur = await _repo.current();
    final levelId = levels.any((e) => e.id == cur['levelId']) ? cur['levelId'] : (levels.isEmpty ? null : levels.first.id);
    final series = levelId == null ? const <SeriesOption>[] : await _repo.activeSeries(levelId);
    final seriesId = series.any((e) => e.id == cur['seriesId']) ? cur['seriesId'] : (series.isEmpty ? null : series.first.id);
    if (!mounted) return;
    setState(() { _levels = levels; _levelId = levelId; _series = series; _seriesId = seriesId; });
  }

  Future<void> _onLevelTap(String v) async {
    final s = await _repo.activeSeries(v);
    if (!mounted) return;
    setState(() { _levelId = v; _series = s; _seriesId = s.isEmpty ? null : s.first.id; });
  }

  Future<void> _save() async {
    if (_levelId == null || _busy) return;
    setState(() => _busy = true);
    final msg = await _repo.change(_levelId!, _seriesId);
    if (!mounted) return;
    setState(() => _busy = false);
    ModernSnackbar.show(context, msg, success: !msg.toLowerCase().contains('invalide') && !msg.toLowerCase().contains('non'));
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_levels.isEmpty) return const SizedBox.shrink();
    return ClassSelectionForm(
      levels: _levels, levelId: _levelId, series: _series, seriesId: _seriesId, busy: _busy,
      onLevelTap: _onLevelTap, onSeriesSelected: (e) => setState(() => _seriesId = e.id), onSave: _save,
    );
  }
}
