import 'package:eduquest/features/marketplace/domain/marketplace_item.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
      appBar: const RuachAppBar(title: 'Detail'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(RuachRadius.lg),
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
              color: RuachColors.cream900,
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
                  borderRadius: BorderRadius.circular(RuachRadius.sm),
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
                    color: RuachColors.cream900,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: RuachButton(
              label: 'Acheter sur le site',
              onPressed: _open,
              icon: PhosphorIconsRegular.arrowSquareOut,
            ),
          ),
        ],
      ),
    );
  }
}
