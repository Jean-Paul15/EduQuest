import 'package:flutter/cupertino.dart';

Future<void> showAccessDeniedDialog({
  required BuildContext context,
  required String accessTier,
  required String sectionLabel,
  required String requiredTier,
}) async {
  await showCupertinoDialog<void>(
    context: context,
    builder: (_) => CupertinoAlertDialog(
      title: const Text('Accès non autorisé'),
      content: Text(
        'Ton accès $accessTier ne permet pas d\'ouvrir $sectionLabel. Ticket requis: $requiredTier.',
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Compris'),
        ),
      ],
    ),
  );
}
