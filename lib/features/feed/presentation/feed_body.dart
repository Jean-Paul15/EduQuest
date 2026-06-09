import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'feed_card.dart';
import 'feed_item.dart';

class FeedBody extends StatelessWidget {
  const FeedBody({
    super.key,
    required this.loading,
    required this.items,
    required this.serie,
    required this.onRefresh,
    required this.onItemTap,
  });
  final bool loading;
  final List<FeedItem> items;
  final String serie;
  final Future<void> Function() onRefresh;
  final void Function(FeedItem) onItemTap;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (items.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'Aucun contenu disponible.',
            style: TextStyle(color: RuachColors.cream500),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: RuachColors.cream50,
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: PageView.builder(
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => FeedCard(
            item: items[i],
            serie: serie,
            onTap: () => onItemTap(items[i]),
          ),
        ),
      ),
    );
  }
}
