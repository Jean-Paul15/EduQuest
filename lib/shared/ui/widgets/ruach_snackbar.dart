import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Updated snackbar with RuachEdu colors.
class RuachSnackbar {
  static void success(BuildContext context, String message) {
    _show(context, message, RuachColors.success600, PhosphorIconsRegular.checkCircle);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, RuachColors.error400, PhosphorIconsRegular.warningCircle);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, RuachColors.info400, PhosphorIconsRegular.info);
  }

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: RuachColors.white, size: 20),
            const SizedBox(width: RuachSpace.s2),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RuachRadius.md)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
