import 'package:eduquest/features/learning/domain/chapter_resource.dart';
import 'package:eduquest/features/learning/presentation/widgets/resource_entry_card.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ResourceListItem extends StatelessWidget {
  const ResourceListItem({
    super.key,
    required this.resource,
    required this.isPdfMode,
    required this.isVideoMode,
    required this.offlineLabel,
    required this.offlineReady,
    required this.onTap,
  });

  final ChapterResource resource;
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
      title: resource.title,
      statusLabel: offlineLabel,
      statusHighlighted: offlineReady,
      icon: icon,
      onTap: onTap,
    );
  }
}
