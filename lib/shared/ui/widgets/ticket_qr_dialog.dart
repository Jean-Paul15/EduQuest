import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ticket_qr_view.dart';
import 'package:flutter/material.dart';

Future<void> showTicketQrDialog(
  BuildContext context, {
  required String title,
  required String code,
}) async {
  final value = code.trim();
  if (value.isEmpty) return;
  await showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(RuachSpace.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: RuachSpace.s3),
            TicketQrView(data: value),
            const SizedBox(height: RuachSpace.s3),
            SelectableText(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: RuachSpace.s1),
            Text(
              "Présente ce billet à l'entrée.",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: RuachSpace.s3),
            RuachButton(
              label: 'Fermer',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    ),
  );
}
