import 'package:eduquest/features/marketplace/domain/marketplace_item.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketplaceItemDetailPage extends StatelessWidget {
  const MarketplaceItemDetailPage({super.key, required this.item});
  final MarketplaceItem item;
  Future<void> _open() async {
    await launchUrl(Uri.parse(item.url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: s.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  item.type.toUpperCase(),
                  style: TextStyle(
                    color: s.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              if (item.priceLabel?.isNotEmpty == true) ...[
                const SizedBox(width: 8),
                Text(
                  item.priceLabel!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _open,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Acheter sur le site'),
            ),
          ),
        ],
      ),
    );
  }
}
