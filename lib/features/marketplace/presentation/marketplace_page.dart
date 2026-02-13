import 'package:eduquest/features/marketplace/data/marketplace_repository.dart';
import 'package:eduquest/features/marketplace/domain/marketplace_item.dart';
import 'package:eduquest/features/marketplace/presentation/marketplace_item_detail_page.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final _repo = MarketplaceRepository();
  final _search = TextEditingController();
  final Map<String, int> _cart = {};
  List<MarketplaceItem> _items = const [];
  String? _type;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
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

  Future<void> _buy(String url) async =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  int get _count => _cart.values.fold(0, (a, b) => a + b);
  void _add(String id) => setState(() => _cart[id] = (_cart[id] ?? 0) + 1);

  Widget _filters() => Column(
    children: [
      TextField(
        controller: _search,
        onSubmitted: (_) => _load(),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, size: 20),
          hintText: 'Recherche...',
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          for (final e in [
            (null, 'Tout'),
            ('book', 'Livres'),
            ('kit', 'Kits'),
            ('ad_slot', 'Ads'),
          ])
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(
                  e.$2,
                  style: TextStyle(
                    color: _type == e.$1
                        ? AppColors.white
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: _type == e.$1,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceCard,
                side: BorderSide(
                  color: _type == e.$1 ? AppColors.primary : AppColors.divider,
                ),
                onSelected: (_) {
                  _type = e.$1;
                  _load();
                },
              ),
            ),
        ],
      ),
    ],
  );

  Widget _list() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) {
      return EmptyState(
        title: 'Aucun article',
        subtitle: 'Changez le filtre ou la recherche.',
        icon: Icons.storefront_outlined,
        actionLabel: 'Reset',
        onAction: () {
          _search.clear();
          _type = null;
          _load();
        },
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (_, i) {
          final e = _items[i];
          return _ItemCard(
            item: e,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MarketplaceItemDetailPage(item: e),
              ),
            ),
            onAdd: () => _add(e.id),
            onBuy: () => _buy(e.url),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return Column(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: _filters()),
          Expanded(child: _list()),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          if (_count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(label: Text('$_count')),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _filters(),
          ),
          Expanded(child: _list()),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.onTap,
    required this.onAdd,
    required this.onBuy,
  });
  final MarketplaceItem item;
  final VoidCallback onTap, onAdd, onBuy;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: s.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: s.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.priceLabel != null)
                    Text(
                      '${item.type.toUpperCase()} - ${item.priceLabel}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onBuy,
              icon: Icon(Icons.open_in_new_rounded, size: 18, color: s.primary),
            ),
          ],
        ),
      ),
    );
  }
}
