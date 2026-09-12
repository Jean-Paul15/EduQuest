import 'package:eduquest/features/class_selection/data/class_selection_repository.dart';
import 'package:eduquest/features/class_selection/domain/level_option.dart';
import 'package:eduquest/features/class_selection/domain/series_option.dart';

class FakeClassSelectionRepository extends ClassSelectionRepository {
  FakeClassSelectionRepository({
    required this.levels,
    required this.seriesByLevel,
    String? levelId,
    String? seriesId,
  }) : _current = {'levelId': levelId, 'seriesId': seriesId};

  final List<LevelOption> levels;
  final Map<String, List<SeriesOption>> seriesByLevel;
  Map<String, String?> _current;

  @override
  Future<List<LevelOption>> activeLevels() async => levels;

  @override
  Future<List<SeriesOption>> activeSeries(String levelId) async =>
      seriesByLevel[levelId] ?? const [];

  @override
  Future<Map<String, String?>> current() async => _current;

  @override
  Future<String> change(String levelId, String? seriesId) async {
    _current = {'levelId': levelId, 'seriesId': seriesId};
    return 'Classe mise à jour.';
  }

  @override
  Future<String> saveProfileSelection(String levelId, String? seriesId) async {
    _current = {'levelId': levelId, 'seriesId': seriesId};
    return 'Classe mise à jour.';
  }
}
