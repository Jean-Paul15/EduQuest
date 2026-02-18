import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

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
          Icons.widgets_rounded,
          'Mettre à jour le widget',
          onWidgetUpdate,
        ),
        _action(
          Icons.add_to_home_screen_rounded,
          "Ajouter le widget à l'accueil",
          onWidgetPin,
        ),
        const Divider(color: AppColors.divider, height: AppSpace.xxl),
        _action(Icons.gavel_rounded, "Conditions d'utilisation", onOpenTerms),
        _action(
          Icons.privacy_tip_rounded,
          'Politique de confidentialité',
          onOpenPrivacy,
        ),
        const Divider(color: AppColors.divider, height: AppSpace.xxl),
        _action(
          Icons.logout_rounded,
          'Se déconnecter',
          onSignOut,
          color: AppColors.error,
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
      icon: Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
      label: Text(
        label,
        style: TextStyle(color: color ?? AppColors.textPrimary),
      ),
    );
  }
}
