import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// Button and chip themes for RuachEdu.
class RuachButtonThemes {
  static ChipThemeData chipTheme({required ColorScheme scheme}) {
    return ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RuachRadius.sm),
      ),
      side: BorderSide(color: scheme.outline),
      backgroundColor: scheme.surfaceContainerHighest,
      selectedColor: RuachColors.gold500,
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      secondaryLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        color: RuachColors.ink100,
      ),
    );
  }

  static FilledButtonThemeData filledButtonTheme({required ColorScheme scheme}) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RuachRadius.full),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          height: 20 / 14,
          letterSpacing: 0.03 * 14,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData outlinedButtonTheme({required ColorScheme scheme}) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RuachRadius.full),
        ),
        side: BorderSide(color: scheme.primary),
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          height: 16 / 12,
          letterSpacing: 0.04 * 12,
        ),
      ),
    );
  }

  static TextButtonThemeData textButtonTheme({required ColorScheme scheme}) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RuachRadius.full),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          height: 16 / 12,
          letterSpacing: 0.04 * 12,
        ),
      ),
    );
  }
}
