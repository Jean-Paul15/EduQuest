import 'package:eduquest/shared/copy/app_copy.dart';
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
      title: const Text(AppCopy.accessDeniedTitle),
      content: Text(
        'Ton accès $accessTier ne permet pas d\'ouvrir $sectionLabel. Ticket requis: $requiredTier.',
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text(AppCopy.understood),
        ),
      ],
    ),
  );
}
