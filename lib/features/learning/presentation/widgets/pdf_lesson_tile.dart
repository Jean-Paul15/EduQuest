import 'package:eduquest/features/learning/domain/pdf_lesson.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
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
    return Container(
      key: ValueKey(lesson.id),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: RuachColors.cream200),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: RuachColors.gold500.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(RuachRadius.sm),
          ),
          child: const Icon(
            PhosphorIconsRegular.filePdf,
            size: 20,
            color: RuachColors.gold500,
          ),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
            color: RuachColors.cream900,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          isOffline ? 'Disponible hors ligne' : 'Synchronisation...',
          style: const TextStyle(fontSize: 12, color: RuachColors.cream700),
        ),
        trailing: const Icon(
          PhosphorIconsRegular.caretRight,
          color: RuachColors.cream700,
        ),
        onTap: onTap,
      ),
    );
  }
}
