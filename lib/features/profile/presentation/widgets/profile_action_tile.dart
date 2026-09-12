import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_tap_scale.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileActionTile extends StatelessWidget {
  const ProfileActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = destructive ? RuachColors.error400 : scheme.onSurface;
    return TapScale(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(RuachRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: RuachSpace.s3),
              Expanded(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
              Icon(PhosphorIconsRegular.caretRight, size: 18, color: destructive ? color : scheme.onSurfaceVariant),
            ]),
          ),
        ),
      ),
    );
  }
}
