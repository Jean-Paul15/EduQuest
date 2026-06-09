import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: RuachColors.cream900,
              ),
            ),
            const SizedBox(height: RuachSpace.s3),
            Container(
              padding: const EdgeInsets.all(RuachSpace.s2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(RuachRadius.lg),
                border: Border.all(color: RuachColors.cream200),
              ),
              child: QrImageView(
                data: value,
                size: 240,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: RuachSpace.s3),
            SelectableText(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: RuachColors.cream900,
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
