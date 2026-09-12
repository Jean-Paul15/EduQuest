import 'package:eduquest/features/orientation/presentation/widgets/labeled_bullet.dart';
import 'package:eduquest/features/user/domain/user_profile.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_outline_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Écran de lancement du test d'orientation — aussi l'écran de retour quand on
/// quitte le test en cours.
class OrientationIntroView extends StatelessWidget {
  const OrientationIntroView({
    super.key,
    required this.hasDraft,
    required this.starting,
    required this.profile,
    required this.onStart,
    required this.onResume,
  });
  final bool hasDraft, starting;
  final UserProfile? profile;
  final VoidCallback onStart, onResume;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(RuachSpace.s4),
      children: [
        Container(
          padding: const EdgeInsets.all(RuachSpace.s5),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(RuachRadius.xl),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(PhosphorIconsRegular.compassTool, size: 34),
              const SizedBox(height: RuachSpace.s3),
              const Text(
                'Bilan d’orientation post-bac',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: RuachSpace.s2),
              Text(
                'Profil ${profile?.serieCode ?? 'D'} • parcours en 5 blocs • '
                'pistes d’études adaptées à ton profil et à ton contexte.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: RuachSpace.s4),
        const LabeledBullet(
          text: 'Questions progressives pour cerner tes intérêts et tes forces.',
        ),
        const LabeledBullet(
          text: 'Disponible en ligne uniquement pour garder un bilan à jour.',
        ),
        const LabeledBullet(
          text: 'Tu peux quitter et reprendre ta session à tout moment.',
        ),
        const LabeledBullet(
          text: 'À la fin : un radar clair et des pistes concrètes à explorer.',
        ),
        const SizedBox(height: RuachSpace.s5),
        RuachButton(
          label: hasDraft ? 'Recommencer depuis le début' : 'Commencer le test',
          loading: starting,
          onPressed: onStart,
        ),
        if (hasDraft) ...[
          const SizedBox(height: RuachSpace.s3),
          RuachOutlineButton(label: 'Reprendre ma session', onPressed: onResume),
        ],
      ],
    );
  }
}
