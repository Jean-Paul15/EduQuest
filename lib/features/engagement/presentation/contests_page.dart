import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/features/engagement/presentation/widgets/engagement_list.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContestsPage extends StatefulWidget {
  const ContestsPage({super.key});

  @override
  State<ContestsPage> createState() => _ContestsPageState();
}

class _ContestsPageState extends State<ContestsPage>
    with AutomaticKeepAliveClientMixin {
  final _repo = EngagementRepository();
  final _analytics = AppAnalytics();
  List<EngagementItem> _items = const [];
  bool _loading = true;
  Future<void> _load({bool forceRefresh = false}) async {
    if (mounted && _items.isEmpty) setState(() => _loading = true);
    final value = await _repo.listContests(forceRefresh: forceRefresh);
    if (!mounted) return;
    setState(() {
      _items = value;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _analytics.track('contests_opened');
    _load(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return EngagementList(
      items: _items,
      loading: _loading,
      emptyLabel: 'Aucun concours disponible',
      onTap: (item) => context.push('/contest/${item.id}'),
      onRefresh: () => _load(forceRefresh: true),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
