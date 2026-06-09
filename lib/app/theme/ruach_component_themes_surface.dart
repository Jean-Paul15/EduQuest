import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// Surface component themes for RuachEdu (inputs, navigation).
class RuachSurfaceThemes {
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
          color: selected ? RuachColors.gold500 : scheme.onSurfaceVariant,
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
}
