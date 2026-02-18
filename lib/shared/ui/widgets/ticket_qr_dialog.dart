import 'package:eduquest/shared/ui/design_tokens.dart';
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
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpace.m),
            Container(
              padding: const EdgeInsets.all(AppSpace.s),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.divider),
              ),
              child: QrImageView(
                data: value,
                size: 240,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpace.m),
            SelectableText(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpace.m),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
