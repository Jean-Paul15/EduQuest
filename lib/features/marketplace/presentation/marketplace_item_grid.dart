import 'package:eduquest/features/marketplace/domain/marketplace_item.dart';
import 'package:eduquest/features/marketplace/presentation/marketplace_item_card.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MarketplaceItemGrid extends StatelessWidget {
  const MarketplaceItemGrid({
    super.key,
    required this.items,
    required this.loading,
    required this.onRefresh,
    required this.onReset,
    required this.onItemTap,
    required this.onBuy,
  });

  final List<MarketplaceItem> items;
  final bool loading;
  final Future<void> Function() onRefresh;
  final VoidCallback onReset;
  final void Function(MarketplaceItem) onItemTap;
  final void Function(MarketplaceItem) onBuy;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: RuachLoader(label: 'Chargement des offres'));
    }
    if (items.isEmpty) {
      return EmptyState(
        title: 'Aucun article',
        subtitle: 'Changez le filtre ou la recherche.',
        icon: PhosphorIconsRegular.storefront,
        actionLabel: 'Reset',
        onAction: onReset,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          // Hauteur fixe avec marge de securite -- l'image de la carte est
          // maintenant en Expanded (absorbe l'espace restant), les elements
          // fixes (titre 2 lignes, prix, ligne type/bouton) sont garantis
          // visibles tant que ce budget leur suffit.
          mainAxisExtent: 260,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final e = items[i];
          return MarketplaceItemCard(
            item: e,
            onTap: () => onItemTap(e),
            onBuy: () => onBuy(e),
          );
        },
      ),
    );
  }
}
