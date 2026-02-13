import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

class ModernSnackbar {
  static void show(BuildContext context, String message, {bool success = true}) {
    final color = success ? AppColors.primary : AppColors.accent;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(success ? Icons.check_circle_rounded : Icons.error_outline_rounded, color: AppColors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message, maxLines: 3, overflow: TextOverflow.ellipsis)),
        ]),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.m)),
      ),
    );
  }
}
