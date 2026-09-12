import 'package:flutter/material.dart';

Color gold500 = const Color(0xFFC89A5A);
Color gold600 = const Color(0xFFB8860B);
Color cream900 = const Color(0xFFF5EFE7);
Color cream700 = const Color(0xFFA09888);
Color cream500 = const Color(0xFF6B6560);
Color cream200 = const Color(0xFF2A2A2A);
Color success600 = const Color(0xFF4ADE80);
Color error400 = const Color(0xFFF87171);
Color ink900 = const Color(0xFF12161E);
Color ink800 = const Color(0xFF1A1E2B);
Color surfaceBase = const Color(0xFF171C27);
Color surfaceRaised = const Color(0xFF1E2634);
Color surfaceStroke = const Color(0xFF303847);
Color goldGlow = const Color(0x33C89A5A);

const cardRadius = Radius.circular(12);
const cardBorderRadius = BorderRadius.all(cardRadius);

/// Recalcule les couleurs du package depuis le thème ambiant de l'app hôte,
/// appelé une fois par [QuizScreen] avant de construire l'arbre — le moteur
/// de quiz suit ainsi le thème clair/sombre choisi par l'utilisateur au lieu
/// d'imposer un thème sombre fixe. [success]/[error] sont fournis par l'app
/// hôte (le package ne dépend pas de sa palette spécifique, seulement du
/// [ColorScheme] Material standard) ; à défaut on retombe sur des rôles
/// Material génériques.
void syncQuizColors(ColorScheme cs, {Color? success, Color? error}) {
  gold500 = cs.primary;
  gold600 = cs.primary;
  cream900 = cs.onSurface;
  cream700 = cs.onSurfaceVariant;
  cream500 = cs.onSurfaceVariant;
  cream200 = cs.outlineVariant;
  success600 = success ?? cs.tertiary;
  error400 = error ?? cs.error;
  ink900 = cs.surface;
  ink800 = cs.surfaceContainerHigh;
  surfaceBase = cs.surfaceContainer;
  surfaceRaised = cs.surfaceContainerHighest;
  surfaceStroke = cs.outlineVariant;
  goldGlow = cs.primary.withValues(alpha: .2);
}
