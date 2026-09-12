import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/sync/service_locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Une recommandation "Pour toi" : jamais un signal déclaratif, toujours issue
/// de l'analyse réelle (méprises classées par l'IA au moment du quiz, maîtrise
/// décroissante, révisions dues — matérialisée 1×/jour par le cron
/// `recommendations-refresh-nightly`, migration 221).
class ReviewRecommendation {
  const ReviewRecommendation({
    required this.chapterId,
    required this.subjectId,
    required this.chapterTitle,
    required this.subjectLabel,
    required this.reasonLabel,
  });

  final String chapterId;
  final String subjectId;
  final String chapterTitle;
  final String subjectLabel;
  final String reasonLabel;

  factory ReviewRecommendation.fromRow(Map<String, dynamic> r) =>
      ReviewRecommendation(
        chapterId: '${r['chapter_id']}',
        subjectId: '${r['subject_id']}',
        chapterTitle: '${(r['chapters'] as Map?)?['title'] ?? ''}',
        subjectLabel: '${(r['subjects'] as Map?)?['label'] ?? ''}',
        reasonLabel: '${r['reason_label'] ?? ''}',
      );

  Map<String, dynamic> toMap() => {
    'chapter_id': chapterId,
    'subject_id': subjectId,
    'chapter_title': chapterTitle,
    'subject_label': subjectLabel,
    'reason_label': reasonLabel,
  };

  factory ReviewRecommendation.fromMap(Map<String, dynamic> m) =>
      ReviewRecommendation(
        chapterId: '${m['chapter_id']}',
        subjectId: '${m['subject_id']}',
        chapterTitle: '${m['chapter_title']}',
        subjectLabel: '${m['subject_label']}',
        reasonLabel: '${m['reason_label']}',
      );
}

class ReviewRepository {
  final _local = LocalJsonCache();
  static const _key = 'learn:for_you';

  /// Gratuit : 1 recommandation/jour. Payant (HALF/FULL) : jusqu'à 10 — la
  /// matérialisation nocturne en calcule déjà 10 au maximum par profil.
  int get _limit =>
      ServiceLocator().accessRepo.lastKnownAccess.isFreeLight ? 1 : 10;

  Future<List<ReviewRecommendation>> recommendations({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _local.readList(_key);
      if (cached != null && cached.isNotEmpty) {
        return cached.map(ReviewRecommendation.fromMap).take(_limit).toList();
      }
    }
    if (!Env.hasSupabase) return const [];
    try {
      final rows = await Supabase.instance.client
          .from('daily_recommendations')
          .select('chapter_id,subject_id,reason_label,rank,chapters(title),subjects(label)')
          .order('rank');
      final out = (rows as List)
          .map((e) => ReviewRecommendation.fromRow(Map<String, dynamic>.from(e as Map)))
          .toList();
      await _local.writeList(_key, out.map((e) => e.toMap()).toList());
      return out.take(_limit).toList();
    } catch (_) {
      return const [];
    }
  }
}
