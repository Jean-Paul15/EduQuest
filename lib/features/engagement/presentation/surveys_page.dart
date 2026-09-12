import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/features/engagement/presentation/widgets/engagement_list.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';

class SurveysPage extends StatefulWidget {
  const SurveysPage({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<SurveysPage> createState() => _SurveysPageState();
}

class _SurveysPageState extends State<SurveysPage>
    with AutomaticKeepAliveClientMixin, RealtimeRefreshable<SurveysPage> {
  @override
  List<String> get realtimeNamespaces => const ['hub:surveys'];

  @override
  Future<void> reloadFromRealtime() => _load(forceRefresh: true);

  final _repo = EngagementRepository();
  final _analytics = AppAnalytics();
  List<EngagementItem> _items = const [];
  bool _loading = true;
  Future<void> _load({bool forceRefresh = false}) async {
    if (mounted && _items.isEmpty) setState(() => _loading = true);
    final value = await _repo.listSurveys(forceRefresh: forceRefresh);
    if (!mounted) return;
    setState(() {
      _items = value;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _analytics.track('surveys_opened', category: 'engagement');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final body = EngagementList(
      items: _items,
      loading: _loading,
      emptyLabel: 'Aucune enquête disponible',
      onTap: (item) async {
        final done = await context.pushNamed<bool>(
          AppRoutes.surveyDetail,
          pathParameters: {'surveyId': item.id},
          queryParameters: {'title': item.title},
        );
        if (done == true) _load(forceRefresh: true);
      },
      onRefresh: () => _load(forceRefresh: true),
    );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: const RuachAppBar(title: 'Sondages', showBack: true),
      body: body,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
