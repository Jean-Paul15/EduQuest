import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/format/engagement_date_format.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EngagementListTile extends StatelessWidget {
  const EngagementListTile({super.key, required this.item, required this.onTap});
  final EngagementItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final date = formatEngagementDate(item.startsAt);
    return Container(
      margin: const EdgeInsets.only(bottom: RuachSpace.s3),
      padding: const EdgeInsets.all(RuachSpace.s3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        border: Border.all(color: s.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(RuachSpace.s2),
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
          const SizedBox(width: RuachSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: text.titleSmall?.copyWith(color: s.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$date  ${item.subtitle}',
                  style: text.bodySmall?.copyWith(color: s.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.requiredTicketType != null)
                  Text(
                    'Ticket ${item.requiredTicketType}',
                    style: text.labelSmall?.copyWith(color: s.primary, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
          Icon(
            PhosphorIconsRegular.caretRight,
            color: s.onSurfaceVariant,
            size: 20,
          ),
        ]),
      ),
    );
  }
}
