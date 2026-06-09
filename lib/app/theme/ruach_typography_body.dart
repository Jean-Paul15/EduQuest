import 'package:flutter/material.dart';

/// Body and label styles for RuachEdu typography.
/// Extracted from RuachTypography to keep file sizes under 100 lines.
class RuachTypographyBody {
  static TextTheme apply(TextTheme base, Color primary, Color secondary) {
    return base.copyWith(
      bodyLarge: base.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 26 / 16,
        letterSpacing: 0,
        color: secondary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 22 / 14,
        letterSpacing: 0,
        color: secondary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        height: 18 / 12,
        letterSpacing: 0,
        color: secondary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0.03 * 14,
        color: primary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.04 * 12,
        color: secondary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 11,
        height: 14 / 11,
        letterSpacing: 0.05 * 11,
        color: secondary,
      ),
    );
  }
}
