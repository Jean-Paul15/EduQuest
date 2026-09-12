import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'feed_item.dart';

class FeedCard extends StatelessWidget {
  const FeedCard({
    super.key,
    required this.item,
    required this.serie,
    required this.onTap,
  });
  final FeedItem item;
  final String serie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Material(
        color: RuachColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(RuachRadius.lg),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(RuachRadius.lg),
              border: Border.all(color: s.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: RuachColors.gold500.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(RuachRadius.sm),
                      ),
                      child: Text(
                        item.tag,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: RuachColors.gold500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      PhosphorIconsRegular.playCircle,
                      color: RuachColors.gold600,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: s.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$serie  ·  ${item.subtitle}',
                  style: TextStyle(
                    fontSize: 14,
                    color: s.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  'Découvre, révise et progresse',
                  style: TextStyle(fontSize: 13, color: s.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
