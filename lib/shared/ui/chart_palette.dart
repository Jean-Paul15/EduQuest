import 'package:flutter/material.dart';

/// Point unique pour toute décision de couleur de dataviz RuachEdu
/// (grapheur de l'assistant, onglet Outils, futurs graphes analytics).
///
/// Deux jeux distincts clair / sombre — pratique standard (Cloudscape, Carbon,
/// Observable). Chaque couleur atteint un contraste ≥ 3:1 avec son fond
/// (`cream50` #FDFAF5 en clair, `ink300` #162240 en sombre — WCAG 1.4.11).
///
/// Positions de teinte reprises d'Okabe-Ito (orange, bleu, vert, rosé) — jeu
/// catégoriel séparable même en deutéranopie — mais recalées sur la palette
/// RuachEdu : série 1 = or de marque, série 2 = bleu de la teinte `ink`,
/// séries 3-4 = vert-pin et rose-vin sourds pour s'accorder au crème. L'ordre
/// évite de rendre adjacente la paire or/vert (la plus confondable en deutan).
class RuachChart {
  const RuachChart._();

  // Contraste vérifié sur cream50 : 3,8 / 6,8 / 5,0 / 5,6 : 1.
  static const _seriesLight = <Color>[
    Color(0xFFAF7415), // or ambré (marque)
    Color(0xFF2A5C86), // bleu ardoise (teinte ink)
    Color(0xFF1E7A63), // vert-pin
    Color(0xFF9C4A6A), // rose-vin
  ];

  // Contraste vérifié sur ink300 : 7,4 / 6,6 / 6,9 / 6,2 : 1.
  static const _seriesDark = <Color>[
    Color(0xFFE3A73E), // or chaud
    Color(0xFF6FAEDC), // bleu ardoise clair
    Color(0xFF4FC0A0), // jade
    Color(0xFFDE8AA6), // rose poudré
  ];

  static List<Color> series(Brightness brightness) =>
      brightness == Brightness.dark ? _seriesDark : _seriesLight;

  static Color seriesAt(Brightness brightness, int index) {
    final s = series(brightness);
    return s[index % s.length];
  }

  /// Asymptote : trait pointillé neutre — jamais rouge « erreur ».
  static Color asymptote(ColorScheme scheme) => scheme.onSurfaceVariant;

  /// Axes passant par zéro dans l'aperçu.
  static Color axis(ColorScheme scheme) => scheme.outline;

  /// Grille fine du plein écran.
  static Color grid(ColorScheme scheme) =>
      scheme.outlineVariant.withValues(alpha: .35);

  /// Point remarquable (racine, extremum).
  static Color marker(ColorScheme scheme) => scheme.onSurface;
}
