import 'package:flutter/widgets.dart';
import 'package:eduquest/features/engagement/presentation/engagement_confirm_dialogs.dart';
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
  final go = await confirmEngagementPayment(context, fee);
  if (go) {
    final launched = await handoff.openPayment(kind: 'contest', id: contestId);
    if (!launched) {
      if (!isMounted()) return;
      if (!context.mounted) return;
      ModernSnackbar.show(
        context,
        'Le service de paiement est indisponible pour le moment.',
        success: false,
      );
    }
  }
  if (isMounted()) reload();
}
