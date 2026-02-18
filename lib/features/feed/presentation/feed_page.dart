import 'dart:async';
import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/presentation/contest_detail_page.dart';
import 'package:eduquest/features/engagement/presentation/event_detail_page.dart';
import 'package:eduquest/features/gamification/data/gamification_repository.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/learning/domain/learning_subject.dart';
import 'package:eduquest/features/learning/presentation/pages/chapter_list_page.dart';
import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:flutter/material.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _analytics = AppAnalytics();
  final _config = AppConfigRepository();
  final _engagement = EngagementRepository();
  final _gamification = GamificationRepository();
  final _catalog = LearningCatalogRepository();
  final _local = LocalJsonCache();
  static final Map<String, List<_FeedItem>> _mem = {};
  String _serie = 'Parcours';
  List<_FeedItem> _items = const [];
  bool _loading = true;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
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
        if (Env.hasSupabase) {
          unawaited(_refresh(key, serie));
        }
        return;
      }
      final localRows = await _local.readList(key);
      if (localRows != null && localRows.isNotEmpty) {
        final localItems = localRows
            .map((e) => _FeedItem.fromMap(e))
            .where((e) => e.kind != _FeedKind.unknown)
            .toList();
        _mem[key] = localItems;
        if (mounted) {
          setState(() {
            _serie = serie;
            _items = localItems;
            _loading = false;
          });
        }
        if (Env.hasSupabase) {
          unawaited(_refresh(key, serie));
        }
        return;
      }
      await _refresh(key, serie);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _refresh(String key, String serie) async {
    try {
      final feedCfg = await _config.loadFeedModules();
      final data = await Future.wait([
        _catalog.subjectsForCourses(),
        _engagement.listContests(forceRefresh: true),
        _engagement.listEvents(forceRefresh: true),
      ]);
      final subjects = data[0] as List<LearningSubject>;
      final contests = data[1] as List<EngagementItem>;
      final events = data[2] as List<EngagementItem>;
      final showCourses = feedCfg['courses'] as bool? ?? true;
      final showContests = feedCfg['contests'] as bool? ?? true;
      final showEvents = feedCfg['events'] as bool? ?? true;
      final limitCourses = feedCfg['courses_limit'] as int? ?? 8;
      final limitContests = feedCfg['contests_limit'] as int? ?? 5;
      final limitEvents = feedCfg['events_limit'] as int? ?? 5;
      final out = <_FeedItem>[
        if (showCourses)
          ...subjects
              .take(limitCourses)
              .map(
                (s) => _FeedItem(
                  id: s.id,
                  kind: _FeedKind.course,
                  tag: 'Cours',
                  title: s.label,
                  subtitle: 'Touchez pour ouvrir le parcours',
                ),
              ),
        if (showContests)
          ...contests
              .take(limitContests)
              .map(
                (c) => _FeedItem(
                  id: c.id,
                  kind: _FeedKind.contest,
                  tag: 'Concours',
                  title: c.title,
                  subtitle: c.subtitle,
                ),
              ),
        if (showEvents)
          ...events
              .take(limitEvents)
              .map(
                (e) => _FeedItem(
                  id: e.id,
                  kind: _FeedKind.event,
                  tag: 'Événement',
                  title: e.title,
                  subtitle: e.subtitle,
                ),
              ),
      ];
      _mem[key] = out;
      await _local.writeList(key, out.map((e) => e.toMap()).toList());
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
    } catch (_) {
      final localRows = await _local.readList(key);
      final localItems = (localRows ?? const [])
          .map((e) => _FeedItem.fromMap(e))
          .where((e) => e.kind != _FeedKind.unknown)
          .toList();
      if (!mounted) return;
      setState(() {
        _serie = serie;
        _items = localItems;
        _loading = false;
      });
    }
  }

  Future<void> _pullRefresh() async {
    final user = await UserProfileRepository().load();
    final serie = '${user.levelCode} ${user.serieCode}';
    final key = 'feed:${user.levelCode}:${user.serieCode}';
    _mem.remove(key);
    await _local.removeByPrefix(key);
    await _refresh(key, serie);
    await _analytics.track(
      'feed_refreshed',
      payload: {'serie': serie, 'items': _items.length},
    );
  }

  Future<void> _open(_FeedItem item) async {
    if (_opening) return;
    _opening = true;
    await _analytics.track(
      'feed_item_tapped',
      payload: {'kind': item.kind.name, 'id': item.id},
    );
    try {
      if (!mounted) return;
      switch (item.kind) {
        case _FeedKind.course:
          final subjectId = item.id;
          if (subjectId.isEmpty) {
            ModernSnackbar.show(
              context,
              'Ce cours est indisponible pour le moment.',
              success: false,
            );
            return;
          }
          final chapters = await _catalog.chaptersBySubject(subjectId);
          if (!mounted) return;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChapterListPage(
                subjectId: subjectId,
                subjectLabel: item.title,
                section: LearningSection.courses,
                initialChapters: chapters,
              ),
            ),
          );
          unawaited(_gamification.claimQuestByCode('open_lesson'));
          return;
        case _FeedKind.contest:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ContestDetailPage(id: item.id)),
          );
          return;
        case _FeedKind.event:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailPage(id: item.id)),
          );
          return;
        case _FeedKind.unknown:
          ModernSnackbar.show(
            context,
            'Action indisponible pour ce contenu.',
            success: false,
          );
          return;
      }
    } finally {
      _opening = false;
    }
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
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: PageView.builder(
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: _items.length,
          itemBuilder: (_, i) => _FeedCard(
            item: _items[i],
            serie: _serie,
            onTap: () => _open(_items[i]),
          ),
        ),
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({
    required this.item,
    required this.serie,
    required this.onTap,
  });
  final _FeedItem item;
  final String serie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
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
                  'Découvre, révise et progresse',
                  style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedItem {
  const _FeedItem({
    required this.id,
    required this.kind,
    required this.tag,
    required this.title,
    required this.subtitle,
  });
  final String id;
  final _FeedKind kind;
  final String tag;
  final String title;
  final String subtitle;

  factory _FeedItem.fromMap(Map<String, dynamic> raw) {
    final kindName = raw['kind']?.toString() ?? '';
    final kind = _FeedKind.values.firstWhere(
      (e) => e.name == kindName,
      orElse: () => _FeedKind.unknown,
    );
    return _FeedItem(
      id: raw['id']?.toString() ?? '',
      kind: kind,
      tag: raw['tag']?.toString() ?? '',
      title: raw['title']?.toString() ?? '',
      subtitle: raw['subtitle']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'kind': kind.name,
    'tag': tag,
    'title': title,
    'subtitle': subtitle,
  };
}

enum _FeedKind { course, contest, event, unknown }
