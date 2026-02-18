import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/features/engagement/presentation/widgets/engagement_list.dart';
import 'package:eduquest/features/surveys/presentation/survey_detail_page.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:flutter/material.dart';

class SurveysPage extends StatefulWidget {
  const SurveysPage({super.key});

  @override
  State<SurveysPage> createState() => _SurveysPageState();
}

class _SurveysPageState extends State<SurveysPage>
    with AutomaticKeepAliveClientMixin {
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
    _analytics.track('surveys_opened');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return EngagementList(
      items: _items,
      loading: _loading,
      emptyLabel: 'Aucune enquête disponible',
      onTap: (item) async {
        final done = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => SurveyDetailPage(id: item.id, title: item.title),
          ),
        );
        if (done == true) _load(forceRefresh: true);
      },
      onRefresh: () => _load(forceRefresh: true),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
