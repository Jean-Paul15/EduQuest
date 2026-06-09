import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EngagementListTile extends StatelessWidget {
  const EngagementListTile({super.key, required this.item, required this.onTap});
  final EngagementItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final date = item.startsAt.toLocal().toString().split(' ').first;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        border: Border.all(color: RuachColors.cream200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: s.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(RuachRadius.sm),
            ),
            child: Icon(
              PhosphorIconsRegular.ticket,
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
                    color: RuachColors.cream900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$date  ${item.subtitle}',
                  style: const TextStyle(
                    color: RuachColors.cream500,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.requiredTicketType != null)
                  Text(
                    'Ticket ${item.requiredTicketType}',
                    style: TextStyle(
                      color: s.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            PhosphorIconsRegular.caretRight,
            color: RuachColors.cream700,
            size: 20,
          ),
        ]),
      ),
    );
  }
}
