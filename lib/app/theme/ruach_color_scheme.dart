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
      surface: RuachColors.ink200,
      surfaceDim: RuachColors.ink200,
      surfaceBright: RuachColors.ink400,
      surfaceContainerLowest: RuachColors.ink50,
      surfaceContainerLow: RuachColors.ink200,
      surfaceContainer: RuachColors.ink300,
      surfaceContainerHigh: RuachColors.ink400,
      onSurface: RuachColors.cream100,
      onSurfaceVariant: RuachColors.cream500,
      outline: RuachColors.ink500,
      outlineVariant: RuachColors.ink400,
      error: RuachColors.error400,
      onError: RuachColors.white,
    );
  }
}
