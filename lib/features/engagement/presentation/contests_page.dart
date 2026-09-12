import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/features/engagement/presentation/widgets/engagement_list.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';

class ContestsPage extends StatefulWidget {
  const ContestsPage({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<ContestsPage> createState() => _ContestsPageState();
}

class _ContestsPageState extends State<ContestsPage>
    with AutomaticKeepAliveClientMixin, RealtimeRefreshable<ContestsPage> {
  @override
  List<String> get realtimeNamespaces => const ['hub:contests'];

  @override
  Future<void> reloadFromRealtime() => _load(forceRefresh: true);

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
    _analytics.track('contests_opened', category: 'engagement');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final body = EngagementList(
      items: _items,
      loading: _loading,
      emptyLabel: 'Aucun concours disponible',
      onTap: (item) => context.push('/contest/${item.id}'),
      onRefresh: () => _load(forceRefresh: true),
    );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: const RuachAppBar(title: 'Concours', showBack: true),
      body: body,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
