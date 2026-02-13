import 'dart:async';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/cache_policy.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _analytics = AppAnalytics();
  final _engagement = EngagementRepository();
  final _catalog = LearningCatalogRepository();
  final _local = LocalJsonCache();
  static final Map<String, List<_FeedItem>> _mem = {};
  String _serie = 'Parcours';
  List<_FeedItem> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await UserProfileRepository().load();
    final serie = '${user.levelCode} ${user.serieCode}';
    final key = 'feed:${user.levelCode}:${user.serieCode}';
    final mem = _mem[key];
    if (mem != null) {
      if (mounted) {
        setState(() {
          _serie = serie;
          _items = mem;
          _loading = false;
        });
      }
      final stale =
          Env.hasSupabase &&
          !await _local.isFresh(key, CachePolicy.feedTimeline);
      if (mem.isEmpty || stale) {
        unawaited(_refresh(key, serie));
      }
      return;
    }
    final localRows = await _local.readList(key);
    if (localRows != null && localRows.isNotEmpty) {
      final localItems = localRows
          .map(
            (e) =>
                _FeedItem('${e['tag']}', '${e['title']}', '${e['subtitle']}'),
          )
          .toList();
      _mem[key] = localItems;
      if (mounted) {
        setState(() {
          _serie = serie;
          _items = localItems;
          _loading = false;
        });
      }
      final stale =
          Env.hasSupabase &&
          !await _local.isFresh(key, CachePolicy.feedTimeline);
      if (localItems.isEmpty || stale) {
        unawaited(_refresh(key, serie));
      }
      return;
    }
    await _refresh(key, serie);
  }

  Future<void> _refresh(String key, String serie) async {
    final data = await Future.wait([
      _catalog.subjectsForCourses(),
      _engagement.listContests(),
      _engagement.listEvents(),
    ]);
    final subjects = data[0] as List;
    final contests = data[1] as List;
    final events = data[2] as List;
    final out = <_FeedItem>[
      ...subjects.take(8).map((s) => _FeedItem('Cours', s.label, 'Apprendre')),
      ...contests
          .take(5)
          .map((c) => _FeedItem('Concours', c.title, c.subtitle)),
      ...events.take(5).map((e) => _FeedItem('Evenement', e.title, e.subtitle)),
    ];
    _mem[key] = out;
    await _local.writeList(
      key,
      out
          .map((e) => {'tag': e.tag, 'title': e.title, 'subtitle': e.subtitle})
          .toList(),
    );
    if (!mounted) return;
    setState(() {
      _serie = serie;
      _items = out;
      _loading = false;
    });
    _analytics.track(
      'feed_opened',
      payload: {'serie': _serie, 'items': out.length},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_items.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'Aucun contenu disponible.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.canvasLight,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _items.length,
        itemBuilder: (_, i) => _FeedCard(item: _items[i], serie: _serie),
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({required this.item, required this.serie});
  final _FeedItem item;
  final String serie;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    item.tag,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.play_circle_outlined,
                  color: AppColors.accent,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$serie  \u00b7  ${item.subtitle}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              'Decouvre, revise et progresse',
              style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedItem {
  const _FeedItem(this.tag, this.title, this.subtitle);
  final String tag, title, subtitle;
}
