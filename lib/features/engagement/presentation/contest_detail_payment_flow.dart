import 'package:flutter/cupertino.dart';
import 'package:eduquest/shared/external/web_checkout_handoff.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';

Future<void> handleContestJoinPayment({
  required BuildContext context,
  required WebCheckoutHandoff handoff,
  required String contestId,
  required double fee,
  required bool Function() isMounted,
  required VoidCallback reload,
}) async {
  if (!isMounted()) return;
  final go = await showCupertinoDialog<bool>(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: const Text('Paiement requis'),
      content: Text('Tu vas être redirigé vers le site pour payer ${fee.toStringAsFixed(0)} FCFA.'),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Plus tard'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Payer maintenant'),
        ),
      ],
    ),
  );
  if (go == true) {
    final launched = await handoff.openPayment(kind: 'contest', id: contestId);
    if (!launched) {
      if (!isMounted()) return;
      ModernSnackbar.show(
        context,
        'Le service de paiement est indisponible pour le moment.',
        success: false,
      );
    }
  }
  if (isMounted()) reload();
}
