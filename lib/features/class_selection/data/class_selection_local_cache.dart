import 'package:eduquest/features/class_selection/domain/level_option.dart';
import 'package:eduquest/features/class_selection/domain/series_option.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';

class ClassSelectionLocalCache {
  final _local = LocalJsonCache();

  Future<Map<String, String?>> current() async {
    final rows = await _local.readList('class:current');
    if (rows == null || rows.isEmpty) {
      return {'levelId': null, 'seriesId': null};
    }
    return {
      'levelId': rows.first['levelId']?.toString(),
      'seriesId': rows.first['seriesId']?.toString(),
    };
  }

  Future<void> saveCurrent(Map<String, String?> value) async =>
      _local.writeList('class:current', [value]);

  Future<List<LevelOption>> levels() async {
    final rows = await _local.readList('class:levels');
    if (rows == null) {
      return const [];
    }
    return rows
        .map(
          (e) => LevelOption(
            id: '${e['id']}',
            code: '${e['code']}',
            label: '${e['label']}',
          ),
        )
        .toList();
  }

  Future<void> saveLevels(List<LevelOption> out) async => _local.writeList(
    'class:levels',
    out.map((e) => {'id': e.id, 'code': e.code, 'label': e.label}).toList(),
  );

  Future<List<SeriesOption>> series(String levelId) async {
    final rows = await _local.readList('class:series:$levelId');
    if (rows == null) {
      return const [];
    }
    return rows
        .map(
          (e) => SeriesOption(
            id: '${e['id']}',
            code: '${e['code']}',
            label: '${e['label']}',
          ),
        )
        .toList();
  }

  Future<void> saveSeries(String levelId, List<SeriesOption> out) async =>
      _local.writeList(
        'class:series:$levelId',
        out.map((e) => {'id': e.id, 'code': e.code, 'label': e.label}).toList(),
      );
}
