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
import 'feed_body.dart';
import 'feed_item.dart';
import 'feed_data_service.dart';
import 'feed_navigator.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = await UserProfileRepository().load();
      final r = await _data.load(user.levelCode, user.serieCode);
      if (!mounted) return;
      setState(() {
        _serie = r.serie;
        _items = r.items;
        _loading = false;
      });
      if (r.fromCache && Env.hasSupabase) {
        final key = 'feed:${user.levelCode}:${user.serieCode}';
        unawaited(_data.refresh(key, r.serie).then((fresh) {
          if (!mounted) return;
          setState(() {
            _serie = fresh.serie;
            _items = fresh.items;
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
      onRefresh: _pullRefresh,
      onItemTap: _open,
    );
  }
}
