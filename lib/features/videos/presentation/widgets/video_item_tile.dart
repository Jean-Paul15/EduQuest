import 'package:eduquest/features/videos/domain/chapter_video.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class VideoItemTile extends StatelessWidget {
  const VideoItemTile({super.key, required this.video, required this.onTap});
  final ChapterVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpace.s),
        padding: const EdgeInsets.all(AppSpace.m),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(AppRadius.xs)),
            child: const Icon(Icons.play_circle_outlined, size: 22, color: AppColors.primary)),
          const SizedBox(width: AppSpace.m),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(video.title, style: const TextStyle(
              fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(video.chapter, style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary)),
            Text(video.sharedAcrossLevels ? 'Partagee entre classes' : 'Specifique a la classe',
              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
        ]),
      ),
    );
  }
}
