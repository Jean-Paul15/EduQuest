import 'package:eduquest/features/learning/domain/chapter_resource.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:flutter/material.dart';

import 'resource_list_item.dart';

class ResourceListBody extends StatelessWidget {
  const ResourceListBody({
    super.key,
    required this.items,
    required this.loading,
    required this.isPdfMode,
    required this.isVideoMode,
    required this.offlineStatus,
    required this.emptyLabel,
    required this.onOpen,
    required this.onRefresh,
  });

  final List<ChapterResource> items;
  final bool loading;
  final bool isPdfMode;
  final bool isVideoMode;
  final Map<String, ({bool ready, String? label})> offlineStatus;
  final String emptyLabel;
  final void Function(ChapterResource r) onOpen;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (loading) return _buildLoading(context);
    if (items.isEmpty) {
      return EmptyState(
        title: 'Rien à afficher',
        subtitle: emptyLabel,
        actionLabel: 'Actualiser',
        onAction: () => onRefresh(),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(RuachSpace.s4),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
        itemBuilder: (_, i) => ResourceListItem(
          resource: items[i],
          isPdfMode: isPdfMode,
          isVideoMode: isVideoMode,
          offlineLabel: offlineStatus[items[i].id]?.label,
          offlineReady: offlineStatus[items[i].id]?.ready ?? false,
          onTap: () => onOpen(items[i]),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(RuachSpace.s4),
    itemCount: 4,
    separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
    itemBuilder: (_, __) => RuachSkeleton(
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RuachRadius.lg),
        ),
      ),
    ),
  );
}
