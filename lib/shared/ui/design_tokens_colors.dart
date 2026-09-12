import 'package:flutter/material.dart';

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

  // ── Ink family (dark surfaces) ── ton chaud (brun-noir), assorti au Gold —
  // ink200-600 étaient des bleus marine (ex. ink300 0xFF162240), en rupture
  // avec l'identité Gold/Ink/Cream : tout le mode sombre en héritait une
  // teinte froide "bleu nuit" au lieu du noir chaud attendu. Rampe refaite
  // dans la même famille chromatique que gold900 (0xFF2E1E04), luminosité
  // croissante — mêmes usages/mêmes rôles qu'avant (surfaces, bordures,
  // overlays), seule la teinte change.
  static const ink50 = Color(0xFF0F0A04);
  static const ink100 = Color(0xFF1A0A00);
  static const ink200 = Color(0xFF201607);
  static const ink300 = Color(0xFF2B1E0D);
  static const ink400 = Color(0xFF372813);
  static const ink500 = Color(0xFF46341A);
  static const ink600 = Color(0xFF5C4522);

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
