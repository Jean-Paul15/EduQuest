import 'package:eduquest/features/videos/domain/chapter_video.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class VideoItemTile extends StatelessWidget {
  const VideoItemTile({super.key, required this.video, required this.onTap});
  final ChapterVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: RuachSpace.s2),
      child: TapScale(
        onTap: onTap,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(RuachRadius.lg),
            child: Container(
              padding: const EdgeInsets.all(RuachSpace.s3),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(color: s.outlineVariant),
                borderRadius: BorderRadius.circular(RuachRadius.lg),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: RuachColors.gold500.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(RuachRadius.md),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: video.thumbnailUrl != null
                        ? Image.network(
                            video.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              PhosphorIconsRegular.playCircle,
                              size: 22,
                              color: RuachColors.gold500,
                            ),
                          )
                        : const Icon(
                            PhosphorIconsRegular.playCircle,
                            size: 22,
                            color: RuachColors.gold500,
                          ),
                  ),
                  const SizedBox(width: RuachSpace.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleSmall?.copyWith(color: s.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          video.chapter,
                          style: text.bodySmall?.copyWith(color: s.onSurfaceVariant),
                        ),
                        const SizedBox(height: RuachSpace.s2),
                        _VideoPill(
                          label: video.sharedAcrossLevels
                              ? 'Partagee'
                              : 'Classe ciblee',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: RuachSpace.s2),
                  Icon(
                    PhosphorIconsRegular.caretRight,
                    color: s.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoPill extends StatelessWidget {
  const _VideoPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RuachSpace.s2, vertical: RuachSpace.s1),
      decoration: BoxDecoration(
        color: s.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(RuachRadius.full),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: s.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
