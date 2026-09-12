import 'package:eduquest/features/profile/presentation/widgets/profile_action_tile.dart';
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
    required this.onOpenMyData,
    required this.onClearCache,
    required this.onSignOut,
  });
  final VoidCallback onWidgetUpdate;
  final VoidCallback onWidgetPin;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;
  final VoidCallback onOpenMyData;
  final VoidCallback onClearCache;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        border: Border.all(color: s.outlineVariant),
      ),
      child: Column(children: [
        ProfileActionTile(icon: PhosphorIconsRegular.squaresFour, label: 'Mettre à jour le widget', onTap: onWidgetUpdate),
        Divider(color: s.outlineVariant, height: 1),
        ProfileActionTile(icon: PhosphorIconsRegular.deviceMobile, label: "Ajouter le widget à l'accueil", onTap: onWidgetPin),
        Divider(color: s.outlineVariant, height: 1),
        ProfileActionTile(icon: PhosphorIconsRegular.scales, label: "Conditions d'utilisation", onTap: onOpenTerms),
        Divider(color: s.outlineVariant, height: 1),
        ProfileActionTile(icon: PhosphorIconsRegular.shieldCheck, label: 'Politique de confidentialité', onTap: onOpenPrivacy),
        Divider(color: s.outlineVariant, height: 1),
        ProfileActionTile(icon: PhosphorIconsRegular.database, label: 'Mes données', onTap: onOpenMyData),
        Divider(color: s.outlineVariant, height: 1),
        ProfileActionTile(icon: PhosphorIconsRegular.trash, label: 'Vider le cache', onTap: onClearCache, destructive: true),
        Divider(color: s.outlineVariant, height: 1),
        ProfileActionTile(icon: PhosphorIconsRegular.signOut, label: 'Se déconnecter', onTap: onSignOut, destructive: true),
      ]),
    );
  }
}
