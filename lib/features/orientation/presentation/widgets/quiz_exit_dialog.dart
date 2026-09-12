import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_text_button.dart';
import 'package:flutter/material.dart';

/// Confirmation avant de quitter un test en cours. Le brouillon est déjà
/// sauvegardé à chaque réponse : quitter n'est jamais destructif.
Future<bool> showQuizExitDialog(BuildContext context) async {
  final quit = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      title: const Text('Quitter le test ?'),
      content: const Text(
        'Ta progression est sauvegardée. Tu pourras reprendre là où tu t’es arrêté.',
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        RuachSpace.s3,
        0,
        RuachSpace.s3,
        RuachSpace.s3,
      ),
      actions: [
        RuachTextButton(
          label: 'Continuer le test',
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        const SizedBox(width: RuachSpace.s2),
        RuachButton(
          label: 'Quitter',
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
  return quit ?? false;
}
