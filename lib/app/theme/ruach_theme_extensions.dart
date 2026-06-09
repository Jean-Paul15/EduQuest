import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

/// ThemeExtension: exposes spacing tokens to widgets via `Theme.of(context).extension<RuachSpaceTokens>()`.
class RuachSpaceTokens extends ThemeExtension<RuachSpaceTokens> {
  const RuachSpaceTokens();
  double get s1 => RuachSpace.s1;
  double get s2 => RuachSpace.s2;
  double get s3 => RuachSpace.s3;
  double get s4 => RuachSpace.s4;
  double get s5 => RuachSpace.s5;
  double get s6 => RuachSpace.s6;
  double get s8 => RuachSpace.s8;
  double get s10 => RuachSpace.s10;
  double get s12 => RuachSpace.s12;
  double get s16 => RuachSpace.s16;
  double get s20 => RuachSpace.s20;
  double get s24 => RuachSpace.s24;

  @override
  RuachSpaceTokens copyWith() => const RuachSpaceTokens();

  @override
  RuachSpaceTokens lerp(covariant ThemeExtension<RuachSpaceTokens>? other, double t) =>
      const RuachSpaceTokens();
}

/// ThemeExtension: exposes motion tokens to widgets.
class RuachMotionTokens extends ThemeExtension<RuachMotionTokens> {
  const RuachMotionTokens();
  Duration get tap => RuachMotion.tap;
  Duration get appear => RuachMotion.appear;
  Duration get pagePush => RuachMotion.pagePush;
  Duration get pagePop => RuachMotion.pagePop;
  Duration get sheetOpen => RuachMotion.sheetOpen;
  Duration get sheetClose => RuachMotion.sheetClose;
  Duration get statusAnim => RuachMotion.statusAnim;
  Duration get progressBar => RuachMotion.progressBar;
  Duration get shimmerLoop => RuachMotion.shimmerLoop;

  @override
  RuachMotionTokens copyWith() => const RuachMotionTokens();

  @override
  RuachMotionTokens lerp(covariant ThemeExtension<RuachMotionTokens>? other, double t) =>
      const RuachMotionTokens();
}

/// ThemeExtension: exposes shadow tokens to widgets.
class RuachShadowTokens extends ThemeExtension<RuachShadowTokens> {
  const RuachShadowTokens();
  List<BoxShadow> get buttonGlow => RuachShadows.buttonGlow;
  List<BoxShadow> get fabGlow => RuachShadows.fabGlow;
  List<BoxShadow> get appBarScroll => RuachShadows.appBarScroll;

  @override
  RuachShadowTokens copyWith() => const RuachShadowTokens();

  @override
  RuachShadowTokens lerp(covariant ThemeExtension<RuachShadowTokens>? other, double t) =>
      const RuachShadowTokens();
}
