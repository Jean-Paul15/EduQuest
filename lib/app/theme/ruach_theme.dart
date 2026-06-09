import 'package:flutter/material.dart';
import 'package:eduquest/app/theme/ruach_color_scheme.dart';
import 'package:eduquest/app/theme/ruach_component_themes.dart';
import 'package:eduquest/app/theme/ruach_theme_extensions.dart';
import 'package:eduquest/app/theme/ruach_typography.dart';

/// Central theme factory for RuachEdu.
/// Returns full ThemeData with custom color scheme, typography,
/// component themes, and extensions for both light and dark modes.
class RuachTheme {
  static ThemeData light() {
    final scheme = RuachColorScheme.light();
    final textTheme = RuachTypography.textTheme(Brightness.light);
    return _base(scheme, textTheme, Brightness.light);
  }

  static ThemeData dark() {
    final scheme = RuachColorScheme.dark();
    final textTheme = RuachTypography.textTheme(Brightness.dark);
    return _base(scheme, textTheme, Brightness.dark);
  }

  static ThemeData _base(ColorScheme scheme, TextTheme textTheme, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: RuachComponentThemes.appBarTheme(scheme: scheme, textTheme: textTheme),
      inputDecorationTheme: RuachComponentThemes.inputTheme(scheme: scheme, brightness: brightness),
      navigationBarTheme: RuachComponentThemes.navTheme(scheme: scheme, brightness: brightness),
      cardTheme: RuachComponentThemes.cardTheme(scheme: scheme),
      chipTheme: RuachComponentThemes.chipTheme(scheme: scheme),
      filledButtonTheme: RuachComponentThemes.filledButtonTheme(scheme: scheme),
      outlinedButtonTheme: RuachComponentThemes.outlinedButtonTheme(scheme: scheme),
      textButtonTheme: RuachComponentThemes.textButtonTheme(scheme: scheme),
      snackBarTheme: RuachComponentThemes.snackBarTheme(scheme: scheme),
      dividerTheme: RuachComponentThemes.dividerTheme(scheme: scheme),
      tabBarTheme: RuachComponentThemes.tabBarTheme(scheme: scheme),
      extensions: const [RuachSpaceTokens(), RuachMotionTokens(), RuachShadowTokens()],
    );
  }
}
