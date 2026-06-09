import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EngagementList extends StatelessWidget {
  const EngagementList({
    super.key,
    required this.items,
    required this.emptyLabel,
    required this.onTap,
    this.onRefresh,
    this.loading = false,
  });
  final List<EngagementItem> items;
  final String emptyLabel;
  final ValueChanged<EngagementItem> onTap;
  final Future<void> Function()? onRefresh;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return EmptyState(
        title: 'Aucun resultat',
        subtitle: emptyLabel,
        icon: PhosphorIconsRegular.magnifyingGlassMinus,
      );
    }
    final s = Theme.of(context).colorScheme;
    final list = ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        final date = item.startsAt.toLocal().toString().split(' ').first;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 150 + (index * 30)),
          builder: (_, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, (1 - v) * 6),
              child: child,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(RuachRadius.lg),
              border: Border.all(color: RuachColors.cream200),
            ),
            child: InkWell(
              onTap: () => onTap(item),
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
          ),
        );
      },
    );
    return onRefresh == null
        ? list
        : RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}
