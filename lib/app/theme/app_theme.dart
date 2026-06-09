import 'package:flutter/material.dart';
import 'package:eduquest/app/theme/ruach_theme.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// Theme facade for RuachEdu.
/// Delegates to the full RuachTheme design system (Gold / Ink / Cream,
/// Plus Jakarta Sans + Fraunces, Phosphor Icons).
/// Kept for backward compatibility — new code should import RuachTheme directly.
class AppTheme {
  /// Legacy constant — prefer RuachColors.gold500 directly.
  static const primaryBlue = RuachColors.gold500;
  /// Legacy constant — prefer RuachColors.gold600 directly.
  static const accentOrange = RuachColors.gold600;

  static ThemeData light() => RuachTheme.light();
  static ThemeData dark() => RuachTheme.dark();
}
