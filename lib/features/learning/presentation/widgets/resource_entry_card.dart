import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ResourceEntryCard extends StatelessWidget {
  const ResourceEntryCard({
    super.key,
    required this.title,
    this.subtitle,
    this.statusLabel,
    this.statusHighlighted = false,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? statusLabel;
  final bool statusHighlighted;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TapScale(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(RuachRadius.lg),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(RuachSpace.s3),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(RuachRadius.lg),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: RuachColors.gold500.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(RuachRadius.md),
                  ),
                  child: Icon(icon, size: 18, color: RuachColors.gold500),
                ),
                const SizedBox(width: RuachSpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (statusLabel != null && statusLabel!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusHighlighted
                                ? scheme.primary.withValues(alpha: .10)
                                : scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(
                              RuachRadius.full,
                            ),
                          ),
                          child: Text(
                            statusLabel!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusHighlighted
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: RuachSpace.s2),
                Icon(
                  PhosphorIconsRegular.caretRight,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
