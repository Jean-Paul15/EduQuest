import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/academic_year.dart';
import '../domain/orientation_constraints.dart';
import '../domain/orientation_recommendation.dart';
import '../domain/recommended_field.dart';
import '../domain/riasec_profile.dart';
import 'orientation_recommendation_mapper.dart';

class OrientationUnavailable implements Exception {
  const OrientationUnavailable(this.message);
  final String message;
}

class OrientationRepository {
  static const _slug = 'scientific-postbac';
  static const _draftKey = 'orientation:scientific:draft';
  static const _resultKey = 'orientation:scientific:result';

  final _auth = AuthRepository();
  final _local = LocalJsonCache();
  final _sb = Supabase.instance.client;
  QuizDefinition? _memo;
  String? _activeVersion;

  String? get activeVersion => _activeVersion;

  Future<QuizDefinition> activeQuestionnaire() async {
    if (_memo != null) return _memo!;
    if (!Env.hasSupabase) {
      throw const OrientationUnavailable(
        'Le module orientation n’est pas configuré.',
      );
    }
    if (!await NetworkProbe.hasConnection()) {
      throw const OrientationUnavailable(
        'L’orientation n’est pas disponible hors ligne.',
      );
    }
    final row = await _sb
        .from('orientation_questionnaires')
        .select('version,qdl_json')
        .eq('slug', _slug)
        .eq('is_active', true)
        .maybeSingle();
    if (row == null) {
      throw const OrientationUnavailable(
        'Aucun questionnaire actif n’a été publié.',
      );
    }
    _activeVersion = row['version']?.toString();
    _memo = const QdlParser().parseFull(
      Map<String, dynamic>.from(row['qdl_json'] as Map),
    );
    return _memo!;
  }

  Future<QuizSessionSnapshot?> loadDraft() async =>
      QuizSessionSnapshot.fromRows(await _local.readList(_draftKey));

  Future<void> saveDraft(QuizSessionSnapshot snapshot) async =>
      _local.writeList(_draftKey, [snapshot.toMap()]);

  Future<void> clearDraft() => _local.removeByPrefix(_draftKey);

  /// Classement déterministe des familles de filières (source de vérité).
  Future<List<RecommendedField>> matchFields({
    required RiasecProfile profile,
    required OrientationConstraints constraints,
    required String seriesCode,
    String? academicYear,
  }) async {
    final rows = await _sb.rpc(
      'orientation_match_fields',
      params: {
        'p_riasec': profile.toJson(),
        'p_constraints': constraints.toJson(),
        'p_series': seriesCode,
        'p_year': academicYear ?? currentAcademicYear(),
      },
    );
    return (rows as List)
        .map((r) => RecommendedField.fromRpcRow(Map<String, dynamic>.from(r)))
        .toList(growable: false);
  }

  /// Analyse IA (narration + citations RAG) par-dessus le classement déterministe.
  /// En cas d’échec réseau, renvoie une recommandation déterministe locale plutôt
  /// qu’une erreur nue.
  Future<OrientationRecommendation> analyzeCompleted({
    required QuizSessionSnapshot snapshot,
    required RiasecProfile profile,
    required OrientationConstraints constraints,
    required List<RecommendedField> fields,
    required String seriesCode,
    required String questionnaireVersion,
    Map<String, dynamic>? learner,
    String? academicYear,
  }) async {
    final uid = _auth.currentUser?.id;
    if (!Env.hasSupabase || uid == null) {
      throw const OrientationUnavailable('Une session active est requise.');
    }
    try {
      final token = _sb.auth.currentSession?.accessToken;
      final res = await _sb.functions.invoke(
        'ai-orientation-analyze',
        headers: token == null ? null : {'Authorization': 'Bearer $token'},
        body: {
          'snapshot': snapshot.toMap(),
          'riasec': profile.toJson(),
          'constraints': constraints.toJson(),
          'fields': [for (final f in fields) f.fieldCode],
          'learner': learner,
          'seriesCode': seriesCode,
          'academicYear': academicYear ?? currentAcademicYear(),
          'questionnaireVersion': questionnaireVersion,
        },
      );
      final json = Map<String, dynamic>.from(res.data as Map);
      final reco = Map<String, dynamic>.from(
        (json['recommendation'] as Map?) ?? json,
      );
      final result = OrientationRecommendationMapper.fromEdgeJson(
        reco,
        profile: profile,
        constraints: constraints,
        fields: fields,
      );
      await _local.writeList(_resultKey, [reco]);
      await clearDraft();
      return result;
    } catch (_) {
      return OrientationRecommendationMapper.deterministic(
        profile: profile,
        constraints: constraints,
        fields: fields,
      );
    }
  }

  /// Dernier bilan mis en cache (consultation hors-ligne).
  Future<Map<String, dynamic>?> cachedResultJson() async {
    final rows = await _local.readList(_resultKey) ?? const [];
    return rows.isEmpty ? null : Map<String, dynamic>.from(rows.first);
  }
}
