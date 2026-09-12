import 'package:flutter/material.dart';
import '../constants.dart';
import '../tokens.dart';

class QuizSurfacePanel extends StatelessWidget {
  const QuizSurfacePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        // Couleur pleine + bordure, aligné sur RuachCourseCard (pas de
        // dégradé ni d'ombre portée — cohérent avec le reste de l'app).
        color: surfaceRaised,
        borderRadius: BorderRadius.circular(QuizRadius.lg),
        border: Border.all(color: surfaceStroke),
      ),
      child: child,
    );
  }
}
