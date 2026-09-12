import 'package:eduquest/features/learning/domain/learning_subject.dart';
import 'package:eduquest/features/learning/presentation/widgets/learning_nav_card.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SubjectTile extends StatelessWidget {
  const SubjectTile({
    super.key,
    required this.subject,
    required this.isOpening,
    required this.onTap,
    this.isExam = false,
  });

  final LearningSubject subject;
  final bool isOpening;
  final VoidCallback onTap;

  /// Section épreuves/examens : `list_exam_subjects` ne renvoie que des matières
  /// ayant au moins un sujet publié — la tuile est donc toujours ouvrable et ne
  /// porte jamais l'état « bientôt disponible » (réservé aux cours vides).
  final bool isExam;

  @override
  Widget build(BuildContext context) {
    final openable = isExam || subject.availableChapterCount > 0;
    return LearningNavCard(
      title: subject.label,
      subtitle: isExam
          ? 'Sujets disponibles'
          : subject.availableChapterCount > 0
              ? '${subject.availableChapterCount} chapitre(s) disponible(s)'
              : 'Contenu bientôt disponible',
      icon: PhosphorIconsRegular.bookOpenText,
      loading: isOpening,
      onTap: openable ? onTap : null,
    );
  }
}
