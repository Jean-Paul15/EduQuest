import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/glass_container.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: s.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(RuachRadius.sm),
              ),
              child: Icon(icon, color: s.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: RuachColors.cream900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: RuachColors.cream500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (onAction == null)
              Icon(
                PhosphorIconsRegular.caretRight,
                color: RuachColors.cream700,
                size: 20,
              ),
            if (onAction != null)
              RuachOutlineButton(
                label: actionLabel ?? 'Voir',
                onPressed: onAction,
                icon: actionIcon ?? PhosphorIconsRegular.arrowSquareOut,
              ),
          ],
        ),
      ),
    );
  }
}
