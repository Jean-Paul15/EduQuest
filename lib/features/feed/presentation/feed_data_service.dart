import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/domain/learning_subject.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'feed_item.dart';

class FeedDataService {
  FeedDataService(this._config, this._engagement, this._catalog, this._local, this._analytics);
  final AppConfigRepository _config;
  final EngagementRepository _engagement;
  final LearningCatalogRepository _catalog;
  final LocalJsonCache _local;
  final AppAnalytics _analytics;
  static final Map<String, List<FeedItem>> _mem = {};

  Future<FeedData> load(String levelCode, String serieCode) async {
    final serie = '$levelCode $serieCode';
    final key = 'feed:$levelCode:$serieCode';
    final mem = _mem[key];
    if (mem != null) {
      return FeedData(serie: serie, items: mem, fromCache: true);
    }
    final local = await _local.readList(key);
    if (local != null && local.isNotEmpty) {
      final items = local
          .map((e) => FeedItem.fromMap(e))
          .where((e) => e.kind != FeedKind.unknown)
          .toList();
      _mem[key] = items;
      return FeedData(serie: serie, items: items, fromCache: true);
    }
    return refresh(key, serie);
  }

  Future<FeedData> refresh(String key, String serie) async {
    try {
      final feedCfg = await _config.loadFeedModules();
      final data = await Future.wait([
        _catalog.subjectsForCourses(),
        _engagement.listContests(forceRefresh: true),
        _engagement.listEvents(forceRefresh: true),
        _catalog.fetchRecommendedChapters(),
      ]);
      final items = buildFeedItems(
        feedCfg: feedCfg,
        subjects: data[0] as List<LearningSubject>,
        contests: data[1] as List<EngagementItem>,
        events: data[2] as List<EngagementItem>,
        recommendedChapters: data[3]
            as List<({String chapterId, String subjectId, String title})>,
      );
      _mem[key] = items;
      await _local.writeList(key, items.map((e) => e.toMap()).toList());
      _analytics.track(
        'feed_opened',
        payload: {'serie': serie, 'items': items.length},
      );
      return FeedData(serie: serie, items: items);
    } catch (_) {
      final local = await _local.readList(key);
      final items = (local ?? const [])
          .map((e) => FeedItem.fromMap(e))
          .where((e) => e.kind != FeedKind.unknown)
          .toList();
      return FeedData(serie: serie, items: items);
    }
  }

  Future<FeedData> pullRefresh(String levelCode, String serieCode) async {
    final key = 'feed:$levelCode:$serieCode';
    _mem.remove(key);
    await _local.removeByPrefix(key);
    return refresh(key, '$levelCode $serieCode');
  }
}

class FeedData {
  const FeedData({required this.serie, required this.items, this.fromCache = false});
  final String serie;
  final List<FeedItem> items;
  final bool fromCache;
}
