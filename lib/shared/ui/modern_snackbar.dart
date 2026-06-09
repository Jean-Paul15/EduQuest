import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/widgets/ruach_snackbar.dart';

/// Legacy snackbar — delegates to RuachSnackbar for consistent RuachEdu colors.
/// Prefer RuachSnackbar.success / .error / .info directly in new code.
class ModernSnackbar {
  static void show(BuildContext context, String message, {bool success = true}) {
    if (success) {
      RuachSnackbar.success(context, message);
    } else {
      RuachSnackbar.error(context, message);
    }
  }
}
