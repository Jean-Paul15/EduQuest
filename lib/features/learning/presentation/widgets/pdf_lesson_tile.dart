import 'package:eduquest/features/learning/domain/pdf_lesson.dart';
import 'package:eduquest/features/learning/presentation/widgets/resource_entry_card.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PdfLessonTile extends StatelessWidget {
  const PdfLessonTile({
    super.key,
    required this.lesson,
    required this.isOffline,
    required this.onTap,
  });

  final PdfLesson lesson;
  final bool isOffline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ResourceEntryCard(
      key: ValueKey(lesson.id),
      title: lesson.title,
      subtitle: 'Document de cours',
      statusLabel: isOffline
          ? 'Disponible hors ligne'
          : 'Préparation locale en cours',
      statusHighlighted: isOffline,
      icon: PhosphorIconsRegular.filePdf,
      onTap: onTap,
    );
  }
}
