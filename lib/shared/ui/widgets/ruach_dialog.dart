import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// Confirmation dialog — 24dp radius, inline buttons.
Future<T?> showRuachDialog<T>(BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  VoidCallback? onConfirm,
  String? cancelLabel,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showDialog<T>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RuachRadius.xl)),
      backgroundColor: isDark ? RuachColors.ink400 : RuachColors.cream50,
      child: Padding(
        padding: const EdgeInsets.all(RuachSpace.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: RuachSpace.s3),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: RuachSpace.s6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (cancelLabel != null)
                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text(cancelLabel)),
                const SizedBox(width: RuachSpace.s2),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onConfirm?.call();
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RuachRadius.full)),
                  ),
                  child: Text(confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
