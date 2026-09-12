import 'package:flutter/widgets.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/presentation/engagement_confirm_dialogs.dart';
import 'package:eduquest/shared/external/web_checkout_handoff.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/widgets/ticket_qr_dialog.dart';

mixin EventDetailApplyActionsMixin<T extends StatefulWidget> on State<T> {
  WebCheckoutHandoff get handoff;
  EngagementRepository get repo;
  bool get busy;
  set busy(bool v);
  String get eventId;
  Future<void> reload();
  Future<bool> confirmApply() => confirmEngagementAction(
    context,
    title: 'Confirmer la postulation',
    message: 'Veux-tu postuler à cet événement maintenant ?',
    confirmLabel: 'Confirmer',
  );

  Future<void> apply() async {
    if (busy) return;
    final ok = await confirmApply();
    if (!ok || !mounted) return;
    setState(() => busy = true);
    final out = await repo.joinEvent(eventId);
    if (!mounted) return;
    final fee = (out['fee_due'] as num?)?.toDouble() ?? 0;
    final needsPay = out['requires_payment'] == true || fee > 0;
    final base = out['message']?.toString() ?? 'Opération effectuée.';
    final success = out['success'] == true;
    final msg = !success
        ? base
        : needsPay
            ? '$base Montant à régler: ${fee.toStringAsFixed(0)} FCFA.'
            : 'Inscription prise en compte. Ton billet est disponible.';
    ModernSnackbar.show(context, msg, success: success);
    if (success && !needsPay) {
      final code = out['pass_code']?.toString() ?? '';
      if (code.isNotEmpty) {
        await showTicketQrDialog(
          context,
          title: 'Billet événement',
          code: code,
        );
      }
    }
    if (success && needsPay) {
      await handlePaymentIfNeeded(fee);
    }
    await reload();
  }
  Future<void> handlePaymentIfNeeded(double fee) async {
    if (!mounted) return;
    final go = await confirmEngagementPayment(context, fee);
    if (!go) return;
    final launched = await handoff.openPayment(kind: 'event', id: eventId);
    if (!launched) {
      if (!mounted) return;
      ModernSnackbar.show(
        context,
        'Le service de paiement est indisponible pour le moment.',
        success: false,
      );
    }
  }
}
