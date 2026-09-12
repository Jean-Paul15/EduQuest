import 'package:eduquest/features/class_selection/data/class_selection_repository.dart';
import 'package:eduquest/features/class_selection/domain/level_option.dart';
import 'package:eduquest/features/class_selection/domain/series_option.dart';
import 'package:eduquest/features/profile/data/profile_setup_repository.dart';
import 'package:eduquest/features/profile/presentation/widgets/profile_setup_gate_view.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/validation/phone_validator.dart';
import 'package:flutter/material.dart';

class ProfileSetupGatePage extends StatefulWidget {
  const ProfileSetupGatePage({
    super.key,
    required this.onDone,
    this.repo,
    this.classRepo,
  });
  final VoidCallback onDone;
  final ProfileSetupRepository? repo;
  final ClassSelectionRepository? classRepo;
  @override
  State<ProfileSetupGatePage> createState() => _ProfileSetupGatePageState();
}

class _ProfileSetupGatePageState extends State<ProfileSetupGatePage> {
  late final ProfileSetupRepository _repo;
  late final ClassSelectionRepository _classRepo;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = true, _saving = false;
  String _countryCode = 'TG';
  List<LevelOption> _levels = const [];
  List<SeriesOption> _series = const [];
  String? _levelId;
  String? _seriesId;
  bool _showName = true;
  bool _showPhone = true;
  bool _showSchooling = true;

  @override
  void initState() {
    super.initState();
    _repo = widget.repo ?? ProfileSetupRepository();
    _classRepo = widget.classRepo ?? ClassSelectionRepository();
    _reload();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    try {
      final s = await _repo.load();
      if (s.complete) {
        if (mounted) widget.onDone();
        return;
      }
      final levels = await _classRepo.activeLevels();
      final levelId = s.levelId ?? (levels.isEmpty ? null : levels.first.id);
      final series = levelId == null
          ? const <SeriesOption>[]
          : await _classRepo.activeSeries(levelId);
      final seriesId = s.seriesId ?? (series.isEmpty ? null : series.first.id);
      if (!mounted) return;
      _nameCtrl.text = s.fullName;
      _phoneCtrl.text = s.whatsappPhone;
      setState(() {
        _countryCode = s.countryCode;
        _levels = levels;
        _levelId = levelId;
        _series = series;
        _seriesId = seriesId;
        _showName = s.needsFullName;
        _showPhone = s.needsPhone;
        _showSchooling = s.needsSchooling;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _levels = const [];
        _series = const [];
      });
    }
  }

  Future<void> _onLevelChanged(String levelId) async {
    setState(() {
      _levelId = levelId;
      _series = const [];
      _seriesId = null;
    });
    final series = await _classRepo.activeSeries(levelId);
    if (!mounted) return;
    setState(() {
      _series = series;
      _seriesId = series.isEmpty ? null : series.first.id;
    });
  }

  Future<void> _continue() async {
    if (_saving) return;
    if (_showName && _nameCtrl.text.trim().length < 3) {
      return ModernSnackbar.show(context, 'Nom trop court.', success: false);
    }
    if (_showPhone) {
      final err = phoneValidationMessage(
        countryCode: _countryCode,
        phone: _phoneCtrl.text,
      );
      if (err != null) {
        return ModernSnackbar.show(context, err, success: false);
      }
    }
    if (_showSchooling && (_levelId == null || _seriesId == null)) {
      return ModernSnackbar.show(
        context,
        'Choisis une classe et une série valides.',
        success: false,
      );
    }
    setState(() => _saving = true);
    try {
      final state = await _repo.finalizeProfile(
        fullName: _showName ? _nameCtrl.text : null,
        whatsappPhone: _showPhone ? _phoneCtrl.text : null,
        levelId: _showSchooling ? _levelId : null,
        seriesId: _showSchooling ? _seriesId : null,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      if (state.complete) return widget.onDone();
      ModernSnackbar.show(
        context,
        'Il reste encore un élément à compléter.',
        success: false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ModernSnackbar.show(context, e.toString().replaceFirst('Bad state: ', ''), success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSetupGateView(
      nameCtrl: _nameCtrl,
      phoneCtrl: _phoneCtrl,
      countryCode: _countryCode,
      loading: _loading,
      saving: _saving,
      showName: _showName,
      showPhone: _showPhone,
      showSchooling: _showSchooling,
      levels: _levels,
      levelId: _levelId,
      series: _series,
      seriesId: _seriesId,
      classBusy: _saving,
      onLevelChanged: _onLevelChanged,
      onSeriesChanged: (value) => setState(() => _seriesId = value.id),
      onContinue: _continue,
    );
  }
}
