import 'package:eduquest/features/learning/domain/chapter_resource.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';

import 'resource_list_item.dart';

class ResourceListBody extends StatelessWidget {
  const ResourceListBody({
    super.key,
    required this.items,
    required this.loading,
    required this.isPdfMode,
    required this.isVideoMode,
    required this.emptyLabel,
    required this.onOpen,
  });

  final List<ChapterResource> items;
  final bool loading;
  final bool isPdfMode;
  final bool isVideoMode;
  final String emptyLabel;
  final void Function(ChapterResource r) onOpen;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) {
      return EmptyState(title: 'Rien a afficher', subtitle: emptyLabel);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(RuachSpace.s4),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
      itemBuilder: (_, i) => ResourceListItem(
        resource: items[i],
        isPdfMode: isPdfMode,
        isVideoMode: isVideoMode,
        onTap: () => onOpen(items[i]),
      ),
    );
  }
}
