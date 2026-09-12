import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

class EventPendingPaymentCard extends StatelessWidget {
  const EventPendingPaymentCard({super.key, required this.pendingFee});

  final double? pendingFee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statut: paiement en attente',
            style: TextStyle(color: RuachColors.gold600),
          ),
          Text(
            'Montant à payer: ${pendingFee?.toStringAsFixed(0) ?? '0'} FCFA',
          ),
        ],
      ),
    );
  }
}
