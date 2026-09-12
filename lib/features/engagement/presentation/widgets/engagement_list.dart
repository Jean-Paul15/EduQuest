import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/features/engagement/presentation/widgets/engagement_list_tile.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
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
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const _EngagementSkeletonTile(),
      );
    }
    if (items.isEmpty) {
      return RuachEmptyState(
        title: 'Rien à afficher',
        subtitle: emptyLabel,
        icon: PhosphorIconsRegular.magnifyingGlassMinus,
        actionLabel: onRefresh == null ? null : 'Actualiser',
        onAction: onRefresh,
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
          child: EngagementListTile(item: item, onTap: () => onTap(item)),
        );
      },
    );
    return onRefresh == null
        ? list
        : RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}

class _EngagementSkeletonTile extends StatelessWidget {
  const _EngagementSkeletonTile();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RuachSkeleton(
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RuachRadius.lg),
          border: Border.all(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}
