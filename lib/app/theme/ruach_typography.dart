import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduquest/app/theme/ruach_typography_body.dart';
import 'package:eduquest/app/theme/ruach_typography_mono.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// Typographic scale per RuachEdu spec.
/// Fraunces for display/headlines, Plus Jakarta Sans for body/UI,
/// JetBrains Mono for code/stats.
class RuachTypography {
  static TextTheme textTheme(Brightness brightness) {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? RuachColors.cream100 : RuachColors.cream900;
    final secondary = isDark ? RuachColors.cream500 : RuachColors.cream500;

    var theme = base.copyWith(
      // ── Display (Fraunces italic) ──
      displayLarge: GoogleFonts.fraunces(
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
        fontSize: 56,
        height: 64 / 56,
        letterSpacing: -0.025 * 56,
        color: primary,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        fontSize: 45,
        height: 52 / 45,
        letterSpacing: -0.02 * 45,
        color: primary,
      ),
      displaySmall: GoogleFonts.fraunces(
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        fontSize: 36,
        height: 44 / 36,
        letterSpacing: -0.015 * 36,
        color: primary,
      ),
      // ── Headlines (Plus Jakarta Sans bold) ──
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 26,
        height: 34 / 26,
        letterSpacing: -0.01 * 26,
        color: primary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 22,
        height: 30 / 22,
        letterSpacing: 0,
        color: primary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 26 / 18,
        letterSpacing: 0,
        color: primary,
      ),
      // ── Titles ──
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 24 / 16,
        letterSpacing: 0.01 * 16,
        color: primary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 22 / 14,
        letterSpacing: 0.01 * 14,
        color: primary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        height: 18 / 12,
        letterSpacing: 0.02 * 12,
        color: secondary,
      ),
    );
    theme = RuachTypographyBody.apply(theme, primary, secondary);
    return theme;
  }

  /// Mono scale for code and stats (JetBrains Mono).
  static TextStyle monoLarge(Brightness brightness) => RuachTypographyMono.large(brightness);
  static TextStyle monoSmall(Brightness brightness) => RuachTypographyMono.small(brightness);
}
