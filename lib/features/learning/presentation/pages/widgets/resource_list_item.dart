import 'package:eduquest/features/learning/domain/chapter_resource.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ResourceListItem extends StatelessWidget {
  const ResourceListItem({
    super.key,
    required this.resource,
    required this.isPdfMode,
    required this.isVideoMode,
    required this.onTap,
  });

  final ChapterResource resource;
  final bool isPdfMode;
  final bool isVideoMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = isPdfMode
        ? PhosphorIconsRegular.filePdf
        : isVideoMode
            ? PhosphorIconsRegular.playCircle
            : PhosphorIconsRegular.browser;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: RuachColors.cream200),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: ListTile(
        title: Text(
          resource.title,
          style: const TextStyle(
            color: RuachColors.cream900,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(icon, color: RuachColors.gold500),
        onTap: onTap,
      ),
    );
  }
}
