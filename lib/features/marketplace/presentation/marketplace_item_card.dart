import 'package:eduquest/features/marketplace/domain/marketplace_item.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MarketplaceItemCard extends StatelessWidget {
  const MarketplaceItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onBuy,
  });
  final MarketplaceItem item;
  final VoidCallback onTap, onBuy;
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final icon = switch (item.type) {
      'book' => PhosphorIconsRegular.bookOpen,
      'kit' => PhosphorIconsRegular.package,
      'ad_slot' => PhosphorIconsRegular.megaphone,
      _ => PhosphorIconsRegular.shoppingBag,
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(RuachRadius.lg),
          border: Border.all(color: RuachColors.cream200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(RuachRadius.md),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(item.imageUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _iconBox(icon, s))
                    : _iconBox(icon, s),
              ),
            ),
            const SizedBox(height: 10),
            Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600,
                  fontSize: 14, color: RuachColors.cream900)),
            const Spacer(),
            if (item.priceLabel != null)
              Text(item.priceLabel!, style: const TextStyle(
                  color: RuachColors.cream500, fontSize: 12)),
            Row(children: [
              Expanded(child: Text(item.type.toUpperCase(),
                  style: const TextStyle(color: RuachColors.cream700,
                      fontSize: 11))),
              IconButton(onPressed: onBuy,
                icon: Icon(PhosphorIconsRegular.arrowSquareOut,
                    size: 18, color: s.primary)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon, ColorScheme s) => Container(
    decoration: BoxDecoration(
      color: s.primary.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(RuachRadius.md),
    ),
    child: Center(child: Icon(icon, color: s.primary, size: 28)),
  );
}
