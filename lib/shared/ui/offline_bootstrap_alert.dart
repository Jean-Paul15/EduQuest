import 'package:flutter/cupertino.dart';

Future<void> showOfflineBootstrapAlert(
  BuildContext context, {
  required String contentLabel,
}) {
  return showCupertinoDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => CupertinoAlertDialog(
      title: const Text('Connexion requise'),
      content: Text(
        'Active ta connexion pour charger $contentLabel une première fois.',
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
