import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileActions extends StatelessWidget {
  const ProfileActions({
    super.key,
    required this.onWidgetUpdate,
    required this.onWidgetPin,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
    required this.onSignOut,
  });

  final VoidCallback onWidgetUpdate;
  final VoidCallback onWidgetPin;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _action(
          PhosphorIconsRegular.squaresFour,
          'Mettre à jour le widget',
          onWidgetUpdate,
        ),
        _action(
          PhosphorIconsRegular.deviceMobile,
          "Ajouter le widget à l'accueil",
          onWidgetPin,
        ),
        const Divider(color: RuachColors.cream200, height: RuachSpace.s6),
        _action(PhosphorIconsRegular.scales, "Conditions d'utilisation", onOpenTerms),
        _action(
          PhosphorIconsRegular.shieldCheck,
          'Politique de confidentialité',
          onOpenPrivacy,
        ),
        const Divider(color: RuachColors.cream200, height: RuachSpace.s6),
        _action(
          PhosphorIconsRegular.signOut,
          'Se déconnecter',
          onSignOut,
          color: RuachColors.error400,
        ),
      ],
    );
  }

  Widget _action(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: color ?? RuachColors.cream500),
      label: Text(
        label,
        style: TextStyle(color: color ?? RuachColors.cream900),
      ),
    );
  }
}
