import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class EngagementLogoBanner extends StatelessWidget {
  const EngagementLogoBanner({super.key, required this.url, required this.tag});

  final String? url;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final safe = url?.trim() ?? '';
    if (safe.isEmpty) return const SizedBox.shrink();
    final s = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.m),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          safe,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: s.primary.withValues(alpha: .08),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image_outlined, color: s.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Logo $tag indisponible',
                    style: TextStyle(color: s.primary),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
