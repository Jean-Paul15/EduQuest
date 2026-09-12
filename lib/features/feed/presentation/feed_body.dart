import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'feed_card.dart';
import 'feed_item.dart';

class FeedBody extends StatelessWidget {
  const FeedBody({
    super.key,
    required this.loading,
    required this.items,
    required this.serie,
    required this.currentIndex,
    required this.isOffline,
    required this.showCachedHint,
    required this.onRefresh,
    required this.onPageChanged,
    required this.onItemTap,
  });
  final bool loading;
  final List<FeedItem> items;
  final String serie;
  final int currentIndex;
  final bool isOffline;
  final bool showCachedHint;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onPageChanged;
  final void Function(FeedItem) onItemTap;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(RuachSpace.s5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: RuachSpace.s3),
                RuachCardSkeleton(),
              ],
            ),
          ),
        ),
      );
    }
    if (items.isEmpty) {
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .18),
              EmptyState(
                title: isOffline ? 'Feed indisponible hors ligne' : 'Aucun contenu disponible',
                subtitle: isOffline
                    ? 'Reconnecte-toi pour charger ton feed personnalisé une première fois.'
                    : 'Aucun contenu n’a encore été préparé pour $serie.',
                actionLabel: 'Réessayer',
                onAction: () => onRefresh(),
              ),
            ],
          ),
        ),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Feed', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          '$serie • ${currentIndex + 1}/${items.length}',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (isOffline || showCachedHint)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(RuachRadius.md),
                      ),
                      child: Text(
                        isOffline ? 'Hors ligne' : 'Cache',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  onPageChanged: onPageChanged,
                  itemCount: items.length,
                  itemBuilder: (_, i) => FeedCard(
                    item: items[i],
                    serie: serie,
                    onTap: () => onItemTap(items[i]),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                'Fais glisser pour parcourir, tire vers le bas pour rafraîchir.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
