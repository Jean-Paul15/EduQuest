import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// Confirmation dialog — 24dp radius, inline buttons. Renvoie true/false selon le bouton
/// pressé (null si le dialogue est fermé sans choix, ex. tap en dehors).
Future<bool?> showRuachDialog(BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Annuler',
  bool destructive = false,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final scheme = Theme.of(context).colorScheme;
  return showDialog<bool>(
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
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(cancelLabel)),
                const SizedBox(width: RuachSpace.s2),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: destructive ? scheme.error : null,
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
