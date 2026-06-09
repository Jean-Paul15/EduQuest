import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ModernSnackbar {
  static void show(BuildContext context, String message, {bool success = true}) {
    final color = success ? RuachColors.gold500 : RuachColors.gold600;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(success ? PhosphorIconsRegular.checkCircle : PhosphorIconsRegular.warningCircle, color: RuachColors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message, maxLines: 3, overflow: TextOverflow.ellipsis)),
        ]),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RuachRadius.lg)),
      ),
    );
  }
}
