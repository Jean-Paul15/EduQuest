import 'dart:async';
import 'package:flutter/material.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/gamification/data/gamification_repository.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/sync/service_locator.dart';
import 'feed_body.dart';
import 'feed_item.dart';
import 'feed_data_service.dart';
import 'feed_navigator.dart';
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with RealtimeRefreshable<FeedPage> {
  @override
  List<String> get realtimeNamespaces => const ['learn', 'chapter', 'hub:contests', 'hub:events'];

  @override
  Future<void> reloadFromRealtime() => _load();

  final _data = FeedDataService(AppConfigRepository(), EngagementRepository(),
      LearningCatalogRepository(), LocalJsonCache(), AppAnalytics());
  final _navigator = FeedNavigator(
    catalog: LearningCatalogRepository(),
    gamification: GamificationRepository(),
  );
  String _serie = 'Parcours';
  List<FeedItem> _items = const [];
  bool _loading = true;
  bool _opening = false;
  bool _fromCache = false;
  int _pageIndex = 0;
  late final OfflineStateNotifier _offlineNotifier;

  @override
  void initState() {
    super.initState();
    _offlineNotifier = ServiceLocator().notifier;
    _offlineNotifier.addListener(_onOfflineChanged);
    _load();
  }

  void _onOfflineChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _offlineNotifier.removeListener(_onOfflineChanged);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final user = await UserProfileRepository().load();
      final r = await _data.load(user.levelCode, user.serieCode);
      if (!mounted) return;
      setState(() {
        _serie = r.serie;
        _items = r.items;
        _fromCache = r.fromCache;
        _pageIndex = 0;
        _loading = false;
      });
      if (r.fromCache && Env.hasSupabase) {
        final key = 'feed:${user.levelCode}:${user.serieCode}';
        unawaited(_data.refresh(key, r.serie).then((fresh) {
          if (!mounted) return;
          setState(() {
            _serie = fresh.serie;
            _items = fresh.items;
            _fromCache = false;
          });
        }));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _pullRefresh() async {
    final user = await UserProfileRepository().load();
    final r = await _data.pullRefresh(user.levelCode, user.serieCode);
    if (!mounted) return;
    setState(() {
      _serie = r.serie;
      _items = r.items;
      _fromCache = false;
      _pageIndex = 0;
    });
  }

  Future<void> _open(FeedItem item) async {
    if (_opening) return;
    _opening = true;
    await AppAnalytics().track(
      'feed_item_tapped',
      payload: {'kind': item.kind.name, 'id': item.id},
    );
    try {
      if (!mounted) return;
      await _navigator.navigate(context, item);
    } finally {
      _opening = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return FeedBody(
      loading: _loading,
      items: _items,
      serie: _serie,
      currentIndex: _pageIndex,
      isOffline: _offlineNotifier.isOffline,
      showCachedHint: _fromCache,
      onRefresh: _pullRefresh,
      onPageChanged: (i) => setState(() => _pageIndex = i),
      onItemTap: _open,
    );
  }
}
