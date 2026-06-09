import 'package:flutter/material.dart';

// ──────────────────────────────────────────
// Ruach Design Tokens — Gold / Ink / Cream
// ──────────────────────────────────────────

/// Base color family tokens for RuachEdu brand system.
/// Gold (primary action), Ink (dark surfaces), Cream (light surfaces).
class RuachColors {
  RuachColors._();

  // ── Gold family (primary / brand) ──
  static const gold50 = Color(0xFFFFFCF4);
  static const gold100 = Color(0xFFFFF4DC);
  static const gold200 = Color(0xFFF7E5B8);
  static const gold300 = Color(0xFFE8C88A);
  static const gold400 = Color(0xFFD4A85C);
  static const gold500 = Color(0xFFC89A5A); // primary brand
  static const gold600 = Color(0xFFA07838);
  static const gold700 = Color(0xFF7A5A24);
  static const gold800 = Color(0xFF543C12);
  static const gold900 = Color(0xFF2E1E04);

  // ── Ink family (dark surfaces) ──
  static const ink50 = Color(0xFF0F0A04);
  static const ink100 = Color(0xFF1A0A00);
  static const ink200 = Color(0xFF12161E);
  static const ink300 = Color(0xFF162240);
  static const ink400 = Color(0xFF1E2F52);
  static const ink500 = Color(0xFF2A3D66);
  static const ink600 = Color(0xFF3A5080);

  // ── Cream family (light surfaces) ──
  static const cream50 = Color(0xFFFDFAF5);
  static const cream100 = Color(0xFFF5EFE4);
  static const cream200 = Color(0xFFEDE4D4);
  static const cream500 = Color(0xFF9C8E7A);
  static const cream700 = Color(0xFF5C5040);
  static const cream900 = Color(0xFF2A2218);

  // ── Status ──
  static const success400 = Color(0xFF4ADE80);
  static const success600 = Color(0xFF16A34A);
  static const warning400 = Color(0xFFFBBF24);
  static const error400 = Color(0xFFF87171);
  static const error404 = Color(0xFFC62828);
  static const info400 = Color(0xFF60A5FA);
  static const streakGold = Color(0xFFFFB800);

  // ── Utility ──
  static const statusGo = success600;
  static const statusCaution = warning400;
  static const white = Colors.white;
  static const black = Colors.black;
  static const transparent = Colors.transparent;
}

// ── Spacing (4dp base) ──

class RuachSpace {
  RuachSpace._();
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s10 = 40.0;
  static const s12 = 48.0;
  static const s16 = 64.0;
  static const s20 = 80.0;
  static const s24 = 96.0;
}

@Deprecated('Use RuachSpace')
class AppSpace {
  AppSpace._();
  static const xs = RuachSpace.s1;
  static const s = RuachSpace.s2;
  static const m = RuachSpace.s3;
  static const l = RuachSpace.s4;
  static const xl = RuachSpace.s5;
  static const xxl = RuachSpace.s6;
  static const xxxl = RuachSpace.s8;
}

// ── Border Radius ──

class RuachRadius {
  RuachRadius._();
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const full = 999.0;
}

@Deprecated('Use RuachRadius')
class AppRadius {
  AppRadius._();
  static const xs = RuachRadius.sm;
  static const s = RuachRadius.md;
  static const m = RuachRadius.lg;
  static const l = 20.0;
  static const xl = RuachRadius.xl;
  static const xxl = 28.0;
  static const card = RuachRadius.lg;
  static const pill = RuachRadius.full;
}

// ── Motion durations ──

class RuachMotion {
  RuachMotion._();
  static const tap = Duration(milliseconds: 100);
  static const appear = Duration(milliseconds: 200);
  static const pagePush = Duration(milliseconds: 280);
  static const pagePop = Duration(milliseconds: 240);
  static const sheetOpen = Duration(milliseconds: 300);
  static const sheetClose = Duration(milliseconds: 260);
  static const statusAnim = Duration(milliseconds: 400);
  static const progressBar = Duration(milliseconds: 600);
  static const shimmerLoop = Duration(milliseconds: 1500);
  static const staggerDelay = Duration(milliseconds: 50);
}

@Deprecated('Use RuachMotion')
class AppMotion {
  AppMotion._();
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
}

// ── Shadows ──

class RuachShadows {
  RuachShadows._();
  static const buttonGlow = [
    BoxShadow(
      color: Color(0x33C89A5A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
  static const fabGlow = [
    BoxShadow(
      color: Color(0x33C89A5A),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
  static const appBarScroll = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
  static const none = <BoxShadow>[];
}

// ── Curves ──

class RuachCurves {
  RuachCurves._();
  static const tap = Curves.easeOut;
  static const appear = Curves.easeOut;
  static const pagePush = Curves.easeOutCubic;
  static const pagePop = Curves.easeInCubic;
  static const sheetOpen = Curves.easeOutCubic;
  static const sheetClose = Curves.easeInCubic;
  static const statusAnim = Curves.easeOutBack;
  static const progressBar = Curves.easeOutQuart;
}

// Keep AppCurves for backward compat but there was no old AppCurves,
// so it's just an alias if anyone used it during early migration.
@Deprecated('Use RuachCurves')
class AppCurves {
  AppCurves._();
  static const fast = Curves.easeInOut;
  static const normal = Curves.easeOut;
  static const slow = Curves.easeOutCubic;
}
