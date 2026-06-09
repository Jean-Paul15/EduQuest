import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// Mono scale for code and stats (JetBrains Mono).
/// Extracted from RuachTypography to keep file sizes under 100 lines.
class RuachTypographyMono {
  static TextStyle large(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return GoogleFonts.jetBrainsMono(
      fontSize: 16,
      height: 24 / 16,
      color: isDark ? RuachColors.cream100 : RuachColors.cream900,
    );
  }

  static TextStyle small(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return GoogleFonts.jetBrainsMono(
      fontSize: 13,
      height: 20 / 13,
      color: isDark ? RuachColors.cream100 : RuachColors.cream900,
    );
  }
}
