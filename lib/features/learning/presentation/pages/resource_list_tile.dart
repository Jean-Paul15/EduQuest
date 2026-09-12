import 'package:eduquest/features/learning/domain/learning_item.dart';
import 'package:eduquest/features/learning/presentation/widgets/resource_entry_card.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ResourceListTile extends StatelessWidget {
  const ResourceListTile({
    super.key,
    required this.item,
    required this.isPdfMode,
    required this.isVideoMode,
    required this.offlineLabel,
    required this.offlineReady,
    required this.onTap,
  });
  final LearningItem item;
  final bool isPdfMode;
  final bool isVideoMode;
  final String? offlineLabel;
  final bool offlineReady;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = isPdfMode
        ? PhosphorIconsRegular.filePdf
        : isVideoMode
        ? PhosphorIconsRegular.playCircle
        : PhosphorIconsRegular.browser;
    return ResourceEntryCard(
      title: item.title,
      subtitle: item.subtitle,
      statusLabel: offlineLabel,
      statusHighlighted: offlineReady,
      icon: icon,
      onTap: onTap,
    );
  }
}
