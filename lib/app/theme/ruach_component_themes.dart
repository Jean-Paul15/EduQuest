import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// Decor and container component themes for RuachEdu.
class RuachComponentThemes {
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

  /// Le défaut Material 3 rend le bouton du switch éteint quasi invisible avec
  /// notre palette (`outline` ≈ `surfaceContainerHighest`, tous deux crème).
  /// On force un contraste net dans les deux états.
  static SwitchThemeData switchTheme({required ColorScheme scheme}) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return scheme.onSurface.withValues(alpha: .28);
        if (states.contains(WidgetState.selected)) return scheme.onPrimary;
        return scheme.onSurfaceVariant; // éteint : bouton bien plus foncé que le rail
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return scheme.surfaceContainerHighest.withValues(alpha: .5);
        if (states.contains(WidgetState.selected)) return scheme.primary;
        return scheme.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.transparent;
        return scheme.outline;
      }),
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
