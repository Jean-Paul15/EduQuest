import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Table de correspondance Material -> Phosphor pour les icônes du package,
/// afin de suivre le langage visuel du reste de l'app RuachEdu (qui utilise
/// Phosphor partout). Un seul point de mapping, pas de décision de design
/// par site d'appel.
class QuizIcons {
  QuizIcons._();

  static const timer = PhosphorIconsRegular.timer;
  static const close = PhosphorIconsRegular.x;
  /// Variante en gras -- utilisee uniquement pour la croix de fermeture de
  /// l'AppBar (question/resultat), maintenant seule sans conteneur autour :
  /// un trait un peu plus epais compense la perte de la pastille de fond
  /// pour rester bien visible/tapable.
  static const closeBold = PhosphorIconsBold.x;
  static const checkCircle = PhosphorIconsRegular.checkCircle;
  static const cancel = PhosphorIconsRegular.xCircle;
  static const skipNext = PhosphorIconsRegular.skipForward;
  static const star = PhosphorIconsRegular.star;
  static const caretDown = PhosphorIconsRegular.caretDown;
  static const headphones = PhosphorIconsRegular.headphones;
  static const copy = PhosphorIconsRegular.copy;
  static const article = PhosphorIconsRegular.fileText;
  static const arrowForward = PhosphorIconsRegular.arrowRight;
  static const info = PhosphorIconsRegular.info;
  static const warning = PhosphorIconsRegular.warning;
  static const functions = PhosphorIconsRegular.function;
  static const clock = PhosphorIconsRegular.clock;
  static const checkBox = PhosphorIconsRegular.checkSquare;
  static const checkBoxOutlineBlank = PhosphorIconsRegular.square;
  static const zoomIn = PhosphorIconsRegular.magnifyingGlassPlus;
  static const brokenImage = PhosphorIconsRegular.imageBroken;
  static const radioButtonChecked = PhosphorIconsRegular.radioButton;
  static const radioButtonUnchecked = PhosphorIconsRegular.circle;
  static const flag = PhosphorIconsRegular.flag;
}
