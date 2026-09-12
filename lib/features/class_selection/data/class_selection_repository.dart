import 'package:eduquest/features/class_selection/data/class_selection_local_cache.dart';
import 'package:eduquest/features/class_selection/domain/level_option.dart';
import 'package:eduquest/features/class_selection/domain/series_option.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/data/live_classes_repository.dart';
import 'package:eduquest/features/learning/data/chapter_content_repository.dart';
import 'package:eduquest/features/learning/data/exam_repository.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/sync/scope_refresh_bus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClassSelectionRepository {
  static const _defaultCountryCode = 'TG';
  final _cache = ClassSelectionLocalCache();
  final _local = LocalJsonCache();

  Future<Map<String, String?>> current() async {
    final local = await _cache.current();
    if (!Env.hasSupabase) return local;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return local;
    try {
      final r = await Supabase.instance.client
          .from('profiles')
          .select('education_level_id,series_id')
          .eq('id', uid)
          .maybeSingle();
      final out = {
        'levelId': r?['education_level_id']?.toString(),
        'seriesId': r?['series_id']?.toString(),
      };
      await _cache.saveCurrent(out);
      return out;
    } catch (_) {
      return local;
    }
  }

  Future<List<LevelOption>> activeLevels() async {
    final local = await _cache.levels();
    if (!Env.hasSupabase) return local;
    try {
      final countryId = await _activeCountryId();
      if (countryId == null) return local;
      final rows = await Supabase.instance.client
          .from('education_levels')
          .select('id,code,label')
          .eq('country_id', countryId)
          .eq('is_active', true)
          .order('sort_order', ascending: true);
      final out = (rows as List)
          .map(
            (e) => LevelOption(
              id: '${e['id']}',
              code: '${e['code']}',
              label: '${e['label']}',
            ),
          )
          .toList();
      await _cache.saveLevels(out);
      return out;
    } catch (_) {
      return local;
    }
  }

  Future<String?> _activeCountryId() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid != null) {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('country_id')
          .eq('id', uid)
          .maybeSingle();
      final countryId = profile?['country_id']?.toString();
      if (countryId != null && countryId.isNotEmpty) return countryId;
    }
    final tg = await Supabase.instance.client
        .from('countries')
        .select('id')
        .eq('code', _defaultCountryCode)
        .maybeSingle();
    if (tg?['id'] != null) return '${tg!['id']}';
    final first = await Supabase.instance.client
        .from('countries')
        .select('id')
        .order('code', ascending: true)
        .limit(1)
        .maybeSingle();
    return first?['id']?.toString();
  }

  Future<List<SeriesOption>> activeSeries(String levelId) async {
    final local = await _cache.series(levelId);
    if (!Env.hasSupabase) return local;
    try {
      final rows = await Supabase.instance.client
          .from('series')
          .select('id,code,label')
          .eq('education_level_id', levelId)
          .eq('is_active', true)
          .order('code', ascending: true);
      final out = (rows as List)
          .map(
            (e) => SeriesOption(
              id: '${e['id']}',
              code: '${e['code']}',
              label: '${e['label']}',
            ),
          )
          .toList();
      await _cache.saveSeries(levelId, out);
      return out;
    } catch (_) {
      return local;
    }
  }

  Future<String> saveProfileSelection(String levelId, String? seriesId) async {
    if (!Env.hasSupabase) return 'Supabase non configuré.';
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return 'Utilisateur non connecté.';
    final validation = await _validateSelection(levelId, seriesId);
    if (validation != null) return validation;
    await Supabase.instance.client
        .from('profiles')
        .update({
          'education_level_id': levelId,
          'series_id': seriesId,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', uid);
    await _afterSelectionSaved(levelId, seriesId);
    return 'Classe mise à jour.';
  }

  Future<String> change(String levelId, String? seriesId) async {
    if (!Env.hasSupabase) return 'Supabase non configuré.';
    final res = await Supabase.instance.client.rpc(
      'change_student_level',
      params: {'p_level_id': levelId, 'p_series_id': seriesId},
    );
    final out = Map<String, dynamic>.from(res as Map);
    final ok = out['success'] == true;
    final msg = '${out['message'] ?? 'Classe mise à jour.'}';
    if (!ok) return msg;
    await _afterSelectionSaved(levelId, seriesId);
    return msg;
  }

  Future<void> saveLocalSelection(String levelId, String? seriesId) async {
    await _afterSelectionSaved(levelId, seriesId);
  }

  Future<String?> _validateSelection(String levelId, String? seriesId) async {
    final level = await Supabase.instance.client
        .from('education_levels')
        .select('id')
        .eq('id', levelId)
        .eq('is_active', true)
        .maybeSingle();
    if (level == null) return 'Classe inactive.';
    if (seriesId == null || seriesId.isEmpty) return null;
    final series = await Supabase.instance.client
        .from('series')
        .select('id')
        .eq('id', seriesId)
        .eq('education_level_id', levelId)
        .eq('is_active', true)
        .maybeSingle();
    return series == null ? 'Série invalide pour cette classe.' : null;
  }

  Future<void> _afterSelectionSaved(String levelId, String? seriesId) async {
    await _cache.saveCurrent({'levelId': levelId, 'seriesId': seriesId});
    await _syncProfileCache(levelId, seriesId);
    await _clearScopedCaches();
    ScopeRefreshBus.bump();
  }

  Future<void> _clearScopedCaches() async {
    await _local.removeByPrefixes([
      'feed:',
      'hub:',
      'learn:',
      'exam:',
      'chapter:',
      'leaderboard:',
      'market:',
      'orientation:',
    ]);
    LearningCatalogRepository.clearMemory();
    ExamRepository.clearMemory();
    ChapterContentRepository.clearMemory();
    EngagementRepository.clearMemory();
    LiveClassesRepository.clearMemory();
  }

  Future<void> _syncProfileCache(String levelId, String? seriesId) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final row = await Supabase.instance.client
          .from('profiles')
          .select('full_name,country_id,whatsapp_phone')
          .eq('id', uid)
          .maybeSingle();
      final cached = await _local.readList('user:profile');
      final cachedName = (cached != null && cached.isNotEmpty)
          ? cached.first['displayName']?.toString()
          : null;
      final full = row?['full_name']?.toString().trim();
      final displayName = (full == null || full.isEmpty)
          ? (cachedName ?? 'Étudiant')
          : full;
      final countryCode = await _loadCode('countries', row?['country_id']);
      final levelCode = await _loadCode('education_levels', levelId);
      final serieCode = await _loadCode('series', seriesId);
      await _local.writeList('user:profile', [
        {
          'displayName': displayName,
          'countryCode': countryCode ?? 'TG',
          'levelCode': levelCode ?? 'Terminale',
          'serieCode': serieCode ?? '',
          'whatsappPhone': row?['whatsapp_phone']?.toString(),
        },
      ]);
    } catch (_) {}
  }

  Future<String?> _loadCode(String table, dynamic id) async {
    if (id == null) return null;
    final row = await Supabase.instance.client
        .from(table)
        .select('code')
        .eq('id', id)
        .maybeSingle();
    return row?['code']?.toString();
  }
}
