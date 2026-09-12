import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/features/user/domain/user_profile.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef VideoFilterBootstrap = ({
  bool fromCache,
  String level,
  String serie,
  List<String> levels,
  List<String> series,
});

class VideoFilterRepository {
  VideoFilterRepository();

  final _local = LocalJsonCache();
  static final Map<String, List<String>> _levelsMem = {};
  static final Map<String, List<String>> _seriesMem = {};
  static final Map<String, String> _countryIdMem = {};

  static void clearMemory() {
    _levelsMem.clear();
    _seriesMem.clear();
    _countryIdMem.clear();
  }

  Future<VideoFilterBootstrap?> peekBootstrap() async {
    final profile = await UserProfileRepository().load();
    return _bootstrapFromLocal(profile);
  }

  Future<bool> hasCache() async {
    final profile = await UserProfileRepository().load();
    return _local.hasKey(_levelsKey(profile.countryCode));
  }

  Future<VideoFilterBootstrap> bootstrap() async {
    final profile = await UserProfileRepository().load();
    final local = await _bootstrapFromLocal(profile);
    if (local != null) return local;
    if (!Env.hasSupabase) return _fallback(profile, fromCache: true);
    return (await _refreshBootstrap(profile)) ??
        _fallback(profile, fromCache: true);
  }

  Future<VideoFilterBootstrap> refreshBootstrap() async {
    final profile = await UserProfileRepository().load();
    return (await _refreshBootstrap(profile)) ??
        (await _bootstrapFromLocal(profile)) ??
        _fallback(profile, fromCache: true);
  }

  Future<List<String>> series(String levelCode) async {
    final profile = await UserProfileRepository().load();
    final local = await _seriesFromLocal(profile.countryCode, levelCode);
    if (local.isNotEmpty || !Env.hasSupabase) return local;
    return (await _refreshSeries(profile.countryCode, levelCode)) ?? local;
  }

  Future<VideoFilterBootstrap?> _bootstrapFromLocal(UserProfile profile) async {
    final levels = await _levelsFromLocal(profile.countryCode);
    if (levels.isEmpty) return null;
    final level = _pick(levels, profile.levelCode);
    final series = await _seriesFromLocal(profile.countryCode, level);
    return (
      fromCache: true,
      level: level,
      serie: _pick(series, profile.serieCode, allowEmpty: true),
      levels: levels,
      series: series,
    );
  }

  Future<VideoFilterBootstrap?> _refreshBootstrap(UserProfile profile) async {
    final levels = await _refreshLevels(profile.countryCode);
    if (levels == null || levels.isEmpty) return null;
    final level = _pick(levels, profile.levelCode);
    final series = await _refreshSeries(profile.countryCode, level) ?? const [];
    return (
      fromCache: false,
      level: level,
      serie: _pick(series, profile.serieCode, allowEmpty: true),
      levels: levels,
      series: series,
    );
  }

  Future<String?> _countryId(String countryCode) async {
    final mem = _countryIdMem[countryCode];
    if (mem != null) return mem;
    final cached = (await _local.readList(
      'video:filters:country:$countryCode',
    ))?.firstOrNull?['id']?.toString();
    if (cached != null && cached.isNotEmpty) {
      return _countryIdMem[countryCode] = cached;
    }
    final row = await Supabase.instance.client
        .from('countries')
        .select('id')
        .eq('code', countryCode)
        .maybeSingle();
    final id = row?['id']?.toString();
    if (id != null && id.isNotEmpty) {
      _countryIdMem[countryCode] = id;
      await _local.writeList('video:filters:country:$countryCode', [
        {'id': id},
      ]);
    }
    return id;
  }

  Future<List<String>> _levelsFromLocal(String countryCode) async {
    final mem = _levelsMem[countryCode];
    if (mem != null) return mem;
    final rows = await _local.readList(_levelsKey(countryCode));
    final out =
        ((rows ?? const [])
                .map((e) => '${e['code']}')
                .where((e) => e.isNotEmpty)
                .toList())
            .toSet()
            .toList();
    if (out.isNotEmpty) _levelsMem[countryCode] = out;
    return out;
  }

  Future<List<String>> _seriesFromLocal(
    String countryCode,
    String levelCode,
  ) async {
    final key = '$countryCode:$levelCode';
    final mem = _seriesMem[key];
    if (mem != null) return mem;
    final rows = await _local.readList(_seriesKey(countryCode, levelCode));
    final out =
        ((rows ?? const [])
                .map((e) => '${e['code']}')
                .where((e) => e.isNotEmpty)
                .toList())
            .toSet()
            .toList();
    _seriesMem[key] = out;
    return out;
  }

  Future<List<String>?> _refreshLevels(String countryCode) async {
    final countryId = await _countryId(countryCode);
    if (countryId == null) return null;
    final query = Supabase.instance.client
        .from('education_levels')
        .select('code')
        .eq('country_id', countryId)
        .eq('is_active', true);
    final rows = await (() async {
      try {
        return await query.order('sort_order', ascending: true);
      } catch (_) {
        return await query.order('label', ascending: true);
      }
    })();
    final out = (rows as List)
        .map((e) => '${e['code']}')
        .where((e) => e.isNotEmpty)
        .toList();
    if (out.isNotEmpty) {
      _levelsMem[countryCode] = out;
      await _local.writeList(
        _levelsKey(countryCode),
        out.map((code) => {'code': code}).toList(),
      );
    }
    return out;
  }

  Future<List<String>?> _refreshSeries(
    String countryCode,
    String levelCode,
  ) async {
    final countryId = await _countryId(countryCode);
    if (countryId == null) return null;
    final level = await Supabase.instance.client
        .from('education_levels')
        .select('id')
        .eq('country_id', countryId)
        .eq('code', levelCode)
        .eq('is_active', true)
        .maybeSingle();
    if (level == null) return const [];
    final rows = await Supabase.instance.client
        .from('series')
        .select('code')
        .eq('education_level_id', level['id'])
        .eq('is_active', true)
        .order('code', ascending: true);
    final out = (rows as List)
        .map((e) => '${e['code']}')
        .where((e) => e.isNotEmpty)
        .toList();
    final key = '$countryCode:$levelCode';
    _seriesMem[key] = out;
    await _local.writeList(
      _seriesKey(countryCode, levelCode),
      out.map((code) => {'code': code}).toList(),
    );
    return out;
  }

  VideoFilterBootstrap _fallback(
    UserProfile profile, {
    required bool fromCache,
  }) {
    final levels = <String>[
      profile.levelCode,
      'Terminale',
      'Première',
      'Seconde',
    ].where((e) => e.isNotEmpty).toSet().toList();
    final series = profile.serieCode.isEmpty
        ? const <String>[]
        : [profile.serieCode];
    return (
      fromCache: fromCache,
      level: _pick(levels, profile.levelCode),
      serie: _pick(series, profile.serieCode, allowEmpty: true),
      levels: levels,
      series: series,
    );
  }

  String _levelsKey(String countryCode) => 'video:filters:levels:$countryCode';
  String _seriesKey(String countryCode, String levelCode) =>
      'video:filters:series:$countryCode:$levelCode';

  String _pick(
    List<String> values,
    String preferred, {
    bool allowEmpty = false,
  }) {
    if (preferred.isNotEmpty && values.contains(preferred)) return preferred;
    if (values.isNotEmpty) return values.first;
    return allowEmpty ? '' : preferred;
  }
}
