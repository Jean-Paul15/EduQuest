import 'package:flutter/material.dart';
export 'design_tokens_colors.dart';

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
