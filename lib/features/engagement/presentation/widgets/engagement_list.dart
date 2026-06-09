import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/features/engagement/presentation/widgets/engagement_list_tile.dart';
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
    final list = ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
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
          child: EngagementListTile(
            item: item,
            onTap: () => onTap(item),
          ),
        );
      },
    );
    return onRefresh == null
        ? list
        : RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}
