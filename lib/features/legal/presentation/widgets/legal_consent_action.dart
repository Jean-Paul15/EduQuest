import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Bouton d'acceptation des CGU/politique de confidentialité, ou état "déjà
/// accepté" si l'utilisateur a déjà consenti à la version actuellement
/// affichée — évite de redemander une acceptation déjà donnée.
class LegalConsentAction extends StatelessWidget {
  const LegalConsentAction({
    super.key,
    required this.currentVersion,
    required this.acceptedVersion,
    required this.acceptedAt,
    required this.accepting,
    required this.onAccept,
  });

  final String currentVersion;
  final String? acceptedVersion;
  final DateTime? acceptedAt;
  final bool accepting;
  final VoidCallback onAccept;

  bool get _isUpToDate =>
      acceptedVersion != null && acceptedVersion == currentVersion;

  @override
  Widget build(BuildContext context) {
    if (_isUpToDate) {
      final date = acceptedAt == null
          ? ''
          : DateFormat("d MMM yyyy", 'fr_FR').format(acceptedAt!.toLocal());
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RuachSpace.s3,
          vertical: RuachSpace.s3,
        ),
        decoration: BoxDecoration(
          color: RuachColors.success600.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(RuachRadius.md),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: RuachColors.success600, size: 18),
            const SizedBox(width: RuachSpace.s2),
            Expanded(
              child: Text(
                date.isEmpty ? 'Déjà accepté' : 'Déjà accepté le $date',
                style: const TextStyle(
                  color: RuachColors.success600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (acceptedVersion != null)
          const Padding(
            padding: EdgeInsets.only(bottom: RuachSpace.s3),
            child: Text(
              'Ce document a été mis à jour depuis votre dernière acceptation.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        RuachButton(
          label: "J'ai lu et j'accepte",
          loading: accepting,
          onPressed: onAccept,
        ),
      ],
    );
  }
}
