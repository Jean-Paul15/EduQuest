import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LearningNavCard extends StatelessWidget {
  const LearningNavCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.loading = false,
    required this.onTap,
    this.footer,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool loading;
  final VoidCallback? onTap;

  /// Contenu additionnel sous le titre/sous-titre, dans la même colonne indentée
  /// (ex. une barre de maîtrise) — jamais utilisé par défaut, n'affecte aucun
  /// appelant existant.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TapScale(
      onTap: loading ? null : onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(RuachRadius.lg),
          onTap: loading ? null : onTap,
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
                      if (footer != null) ...[
                        const SizedBox(height: RuachSpace.s2),
                        footer!,
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: RuachSpace.s2),
                loading
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      )
                    : Icon(
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
