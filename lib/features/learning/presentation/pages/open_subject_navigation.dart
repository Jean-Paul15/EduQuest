import 'dart:async';
import 'package:eduquest/features/learning/data/exam_repository.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/data/learning_warmup_service.dart';
import 'package:eduquest/features/learning/domain/exam_category.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/learning/domain/learning_subject.dart';
import 'package:eduquest/features/learning/presentation/pages/chapter_list_page.dart';
import 'package:eduquest/features/learning/presentation/pages/exam_list_page.dart';
import 'package:eduquest/features/learning/presentation/pages/show_access_denied_dialog.dart';
import 'package:flutter/material.dart';
Future<void> openSubjectNavigation({
  required BuildContext context,
  required LearningSubject subject,
  required LearningSection section,
  required ExamCategory? examCategory,
  required bool canOpenSection,
  required String accessTier,
  required String requiredTier,
  required ExamRepository examRepo,
  required LearningCatalogRepository catalogRepo,
  required LearningWarmupService warmupService,
  required VoidCallback onOpeningStarted,
  required VoidCallback onOpeningFinished,
  required bool Function() isMounted,
}) async {
  if (!canOpenSection) {
    await showAccessDeniedDialog(
      context: context,
      accessTier: accessTier,
      sectionLabel: section.label,
      requiredTier: requiredTier,
    );
    return;
  }
  onOpeningStarted();
  final cat = examCategory;
  try {
    if (!isMounted()) return;
    final d = const Duration(milliseconds: 1800);
    if (cat != null) {
      final papers = await examRepo.listBySubject(subjectId: subject.id, category: cat).timeout(d);
      if (!isMounted()) return;
      // ignore: use_build_context_synchronously — guarded by isMounted() above
      await Navigator.push(context, MaterialPageRoute(builder: (_) => ExamListPage(
        subjectId: subject.id, subjectLabel: subject.label, category: cat, initialEntries: papers,
      )));
    } else {
      final chapters = await catalogRepo.chaptersBySubject(subject.id).timeout(d);
      if (!isMounted()) return;
      unawaited(warmupService.warmBeforeOpenSubject(section, subject.id));
      // ignore: use_build_context_synchronously — guarded by isMounted() above
      await Navigator.push(context, MaterialPageRoute(builder: (_) => ChapterListPage(
        subjectId: subject.id, subjectLabel: subject.label, section: section, initialChapters: chapters,
      )));
    }
  } catch (_) {
    if (!isMounted()) return;
    if (cat != null) {
      // ignore: use_build_context_synchronously — guarded by isMounted() above
      await Navigator.push(context, MaterialPageRoute(builder: (_) => ExamListPage(
        subjectId: subject.id, subjectLabel: subject.label, category: cat,
      )));
    } else {
      // ignore: use_build_context_synchronously — guarded by isMounted() above
      await Navigator.push(context, MaterialPageRoute(builder: (_) => ChapterListPage(
        subjectId: subject.id, subjectLabel: subject.label, section: section,
      )));
    }
  } finally {
    if (isMounted()) onOpeningFinished();
  }
}
