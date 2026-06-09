import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_chip.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Standard course card with image banner, tag, title, subtitle, progress, footer.
class RuachCourseCard extends StatelessWidget {
  const RuachCourseCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.category,
    this.description,
    this.duration,
    this.level,
    this.progress = 0,
    this.onTap,
  });
  final String title;
  final String? imageUrl, category, description, duration, level;
  final double progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RuachRadius.lg),
          border: Border.all(color: scheme.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Banner
            SizedBox(
              height: 140,
              width: double.infinity,
              child: imageUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(isDark)),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, isDark ? RuachColors.ink300 : RuachColors.cream100],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : _placeholder(isDark),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(RuachSpace.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category != null)
                    RuachChip(label: category!.toUpperCase()),
                  const SizedBox(height: RuachSpace.s2),
                  Text(title, style: Theme.of(context).textTheme.titleLarge, maxLines: 2),
                  if (description != null) ...[
                    const SizedBox(height: RuachSpace.s1),
                    Text(description!, style: Theme.of(context).textTheme.bodySmall, maxLines: 2),
                  ],
                  if (progress > 0) ...[
                    const SizedBox(height: RuachSpace.s3),
                    RuachProgressBar(value: progress),
                  ],
                  if (duration != null || level != null) ...[
                    const SizedBox(height: RuachSpace.s3),
                    Row(
                      children: [
                        if (duration != null) ...[
                          Icon(PhosphorIconsRegular.clock, size: 14, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(duration!, style: Theme.of(context).textTheme.labelSmall),
                        ],
                        const Spacer(),
                        if (level != null) Text(level!, style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(bool isDark) => Container(
    color: isDark ? RuachColors.ink400 : RuachColors.cream100,
    child: const Center(child: Icon(PhosphorIconsRegular.book, size: 32, color: RuachColors.cream500)),
  );
}

