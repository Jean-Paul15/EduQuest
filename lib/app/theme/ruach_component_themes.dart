import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// M3 component themes for RuachEdu.
/// Defines Button, Input, Card, Chip, Navigation, AppBar, SnackBar,
/// Divider, and TabBar themes per spec.
class RuachComponentThemes {
  static InputDecorationTheme inputTheme({
    required ColorScheme scheme,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? RuachColors.ink400 : RuachColors.cream100,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: RuachSpace.s4,
        vertical: RuachSpace.s4,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RuachRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RuachRadius.md),
        borderSide: BorderSide(
          color: isDark ? RuachColors.ink500 : RuachColors.cream200,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RuachRadius.md),
        borderSide: const BorderSide(color: RuachColors.gold500, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RuachRadius.md),
        borderSide: const BorderSide(color: RuachColors.error400),
      ),
      hintStyle: TextStyle(
        color: scheme.onSurfaceVariant,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  static NavigationBarThemeData navTheme({
    required ColorScheme scheme,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    return NavigationBarThemeData(
      indicatorColor: Colors.transparent,
      backgroundColor: isDark ? RuachColors.ink300 : RuachColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected
              ? RuachColors.gold500
              : scheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? RuachColors.gold500 : scheme.onSurfaceVariant,
          size: 24,
        );
      }),
    );
  }

  static CardThemeData cardTheme({required ColorScheme scheme}) {
    return CardThemeData(
      color: scheme.surfaceContainerHighest,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        side: BorderSide(color: scheme.outline),
      ),
    );
  }

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

  static FilledButtonThemeData filledButtonTheme({
    required ColorScheme scheme,
  }) {
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

  static OutlinedButtonThemeData outlinedButtonTheme({
    required ColorScheme scheme,
  }) {
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

  static AppBarTheme appBarTheme({
    required ColorScheme scheme,
    required TextTheme textTheme,
  }) {
    return AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: true,
      titleTextStyle: textTheme.headlineSmall,
    );
  }

  static SnackBarThemeData snackBarTheme({required ColorScheme scheme}) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RuachRadius.md),
      ),
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: TextStyle(
        color: scheme.onInverseSurface,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static DividerThemeData dividerTheme({required ColorScheme scheme}) {
    return DividerThemeData(
      color: scheme.outline,
      thickness: 1,
      space: 0,
    );
  }

  static TabBarThemeData tabBarTheme({required ColorScheme scheme}) {
    return TabBarThemeData(
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurfaceVariant,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      unselectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    );
  }
}

