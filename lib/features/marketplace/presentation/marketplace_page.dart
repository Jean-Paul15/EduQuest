import 'dart:async';
import 'package:eduquest/features/marketplace/data/marketplace_repository.dart';
import 'package:eduquest/features/marketplace/domain/marketplace_item.dart';
import 'package:eduquest/features/marketplace/presentation/marketplace_filters.dart';
import 'package:eduquest/features/marketplace/presentation/marketplace_item_detail_page.dart';
import 'package:eduquest/features/marketplace/presentation/marketplace_item_grid.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage>
    with RealtimeRefreshable<MarketplacePage> {
  @override
  List<String> get realtimeNamespaces => const ['market'];

  @override
  Future<void> reloadFromRealtime() => _load();

  final _repo = MarketplaceRepository();
  final _analytics = AppAnalytics();
  final _search = TextEditingController();
  List<MarketplaceItem> _items = const [];
  String? _type;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_analytics.track('marketplace_opened', category: 'marketplace'));
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _repo.search(query: _search.text, type: _type);
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  void _onTypeChanged(String? v) {
    _type = v;
    _load();
  }

  void _reset() {
    _search.clear();
    _type = null;
    _load();
  }

  Future<void> _buy(MarketplaceItem item) async {
    unawaited(
      _analytics.track(
        'marketplace_checkout_opened',
        category: 'marketplace',
        targetType: item.type,
        targetId: item.id,
      ),
    );
    await launchUrl(Uri.parse(item.url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final filters = MarketplaceFilters(
      controller: _search,
      selectedType: _type,
      onSearch: _load,
      onTypeChanged: _onTypeChanged,
    );
    final grid = MarketplaceItemGrid(
      items: _items,
      loading: _loading,
      onRefresh: _load,
      onReset: _reset,
      onItemTap: (item) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MarketplaceItemDetailPage(item: item),
        ),
      ),
      onBuy: _buy,
    );
    if (widget.embedded) {
      return Column(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: filters),
          Expanded(child: grid),
        ],
      );
    }
    return Scaffold(
      appBar: const RuachAppBar(title: 'Marketplace', showBack: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: filters,
          ),
          Expanded(child: grid),
        ],
      ),
    );
  }
}
