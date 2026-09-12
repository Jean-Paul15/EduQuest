import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// Custom ColorScheme for RuachEdu dark and light modes.
/// Dark mode uses ink-200 surface, light mode uses cream-50.
class RuachColorScheme {
  static ColorScheme light() {
    return ColorScheme.fromSeed(
      seedColor: RuachColors.gold500,
      brightness: Brightness.light,
      primary: RuachColors.gold700,
      onPrimary: RuachColors.cream50,
      primaryContainer: RuachColors.gold100,
      onPrimaryContainer: RuachColors.gold900,
      secondary: RuachColors.gold600,
      onSecondary: RuachColors.cream50,
      secondaryContainer: RuachColors.gold200,
      onSecondaryContainer: RuachColors.gold800,
      surface: RuachColors.cream50,
      surfaceDim: RuachColors.cream100,
      surfaceBright: RuachColors.white,
      surfaceContainerLowest: RuachColors.white,
      surfaceContainerLow: RuachColors.cream50,
      surfaceContainer: RuachColors.cream100,
      surfaceContainerHigh: RuachColors.cream200,
      // Sans cet override, ColorScheme.fromSeed derive ce ton depuis la
      // palette neutre generee du seed gold -- un gris quasi-blanc, pas
      // du creme. Reutilise cream200 (dernier ton creme disponible) plutot
      // que d'introduire un nouveau token.
      surfaceContainerHighest: RuachColors.cream200,
      onSurface: RuachColors.cream900,
      onSurfaceVariant: RuachColors.cream500,
      outline: RuachColors.cream200,
      outlineVariant: RuachColors.cream100,
      error: RuachColors.error400,
      onError: RuachColors.white,
    );
  }

  static ColorScheme dark() {
    return ColorScheme.fromSeed(
      seedColor: RuachColors.gold500,
      brightness: Brightness.dark,
      primary: RuachColors.gold400,
      onPrimary: RuachColors.ink100,
      primaryContainer: RuachColors.gold900,
      onPrimaryContainer: RuachColors.gold200,
      secondary: RuachColors.gold500,
      onSecondary: RuachColors.ink100,
      secondaryContainer: RuachColors.gold800,
      onSecondaryContainer: RuachColors.gold200,
      // Surfaces — progressively lighter for depth
      surface: RuachColors.ink300,
      surfaceDim: RuachColors.ink200,
      surfaceBright: RuachColors.ink500,
      surfaceContainerLowest: RuachColors.ink100,
      surfaceContainerLow: RuachColors.ink200,
      surfaceContainer: RuachColors.ink400,
      surfaceContainerHigh: RuachColors.ink500,
      surfaceContainerHighest: RuachColors.ink500,
      // Text — brighter for readability on dark
      onSurface: RuachColors.cream50,
      onSurfaceVariant: RuachColors.cream200,
      // Borders — visible against dark surfaces
      outline: RuachColors.ink600,
      outlineVariant: RuachColors.ink500,
      error: RuachColors.error400,
      onError: RuachColors.white,
    );
  }
}
