import 'package:eduquest/features/videos/domain/chapter_video.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class VideoItemTile extends StatelessWidget {
  const VideoItemTile({super.key, required this.video, required this.onTap});
  final ChapterVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: RuachSpace.s2),
        padding: const EdgeInsets.all(RuachSpace.s3),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: RuachColors.cream200),
          borderRadius: BorderRadius.circular(RuachRadius.lg),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: RuachColors.gold500.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(RuachRadius.sm)),
            child: const Icon(PhosphorIconsRegular.playCircle, size: 22, color: RuachColors.gold500)),
          const SizedBox(width: RuachSpace.s3),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(video.title, style: const TextStyle(
              fontWeight: FontWeight.w500, color: RuachColors.cream900)),
            const SizedBox(height: 2),
            Text(video.chapter, style: const TextStyle(
              fontSize: 12, color: RuachColors.cream500)),
            Text(video.sharedAcrossLevels ? 'Partagee entre classes' : 'Specifique a la classe',
              style: const TextStyle(fontSize: 11, color: RuachColors.cream700)),
          ])),
          const Icon(PhosphorIconsRegular.caretRight, color: RuachColors.cream700),
        ]),
      ),
    );
  }
}
