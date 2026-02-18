import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/features/engagement/presentation/event_detail_page.dart';
import 'package:eduquest/features/engagement/presentation/widgets/engagement_list.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with AutomaticKeepAliveClientMixin {
  final _repo = EngagementRepository();
  final _analytics = AppAnalytics();
  List<EngagementItem> _items = const [];
  bool _loading = true;
  Future<void> _load({bool forceRefresh = false}) async {
    if (mounted && _items.isEmpty) setState(() => _loading = true);
    final value = await _repo.listEvents(forceRefresh: forceRefresh);
    if (!mounted) return;
    setState(() {
      _items = value;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _analytics.track('events_opened');
    _load(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return EngagementList(
      items: _items,
      loading: _loading,
      emptyLabel: 'Aucun événement disponible',
      onTap: (item) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailPage(id: item.id)),
      ),
      onRefresh: () => _load(forceRefresh: true),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
