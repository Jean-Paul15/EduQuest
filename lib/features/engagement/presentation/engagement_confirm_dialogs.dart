import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/widgets/ruach_dialog.dart';

/// Dialogue de confirmation Material maison, partagé par Concours et Événements — remplace
/// les anciens CupertinoAlertDialog (style iOS incohérent avec le reste de l'app).
Future<bool> confirmEngagementAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Annuler',
  bool destructive = false,
}) async {
  final result = await showRuachDialog(
    context,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    cancelLabel: cancelLabel,
    destructive: destructive,
  );
  return result ?? false;
}

/// Dialogue "paiement requis" — dupliqué à l'identique auparavant entre concours et
/// événements, factorisé ici.
Future<bool> confirmEngagementPayment(BuildContext context, double fee) => confirmEngagementAction(
  context,
  title: 'Paiement requis',
  message: 'Tu vas être redirigé vers le site pour payer ${fee.toStringAsFixed(0)} FCFA.',
  confirmLabel: 'Payer maintenant',
  cancelLabel: 'Plus tard',
);
