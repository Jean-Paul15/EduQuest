import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_outline_button.dart';
import 'package:eduquest/shared/ui/widgets/ticket_qr_dialog.dart';

class ContestDetailAppliedCard extends StatelessWidget {
  const ContestDetailAppliedCard({super.key, required this.fee, required this.qrCode});
  final double? fee;
  final String? qrCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statut: appliqué', style: TextStyle(color: RuachColors.success600)),
          if (fee != null && fee! > 0) Text('Montant réglé: ${fee!.toStringAsFixed(0)} FCFA'),
          if ((qrCode ?? '').isNotEmpty) ...[
            const SizedBox(height: RuachSpace.s2),
            RuachOutlineButton(
              label: 'Afficher le QR en grand',
              onPressed: () => showTicketQrDialog(context, title: 'Billet concours', code: qrCode!),
              icon: PhosphorIconsRegular.qrCode,
            ),
          ],
        ],
      ),
    );
  }
}

class ContestDetailPendingPaymentCard extends StatelessWidget {
  const ContestDetailPendingPaymentCard({super.key, required this.fee});
  final double? fee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Statut: paiement en attente', style: TextStyle(color: RuachColors.gold600)),
          Text('Montant à payer: ${fee?.toStringAsFixed(0) ?? '0'} FCFA'),
        ],
      ),
    );
  }
}

class ContestDetailCancelledCard extends StatelessWidget {
  const ContestDetailCancelledCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: const Text(
        'Statut: participation annulée. Tu peux repostuler si le concours est toujours ouvert.',
        style: TextStyle(color: RuachColors.warning400),
      ),
    );
  }
}
