import 'dart:async';
import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/learning/data/exam_repository.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/data/learning_warmup_service.dart';
import 'package:eduquest/features/learning/domain/exam_category.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/learning/domain/learning_subject.dart';

Future<void> loadSectionSubjects({
  required LearningSection section,
  required ExamRepository examRepo,
  required LearningCatalogRepository catalogRepo,
  required AccessRepository accessRepo,
  required AppConfigRepository configRepo,
  required LearningWarmupService warmupService,
  required bool Function() isMounted,
  required void Function(List<LearningSubject> items, AccessState access, Map<String, String> learningAccess) onDataLoaded,
  required Future<void> Function({required bool hadCache, required String label}) warnOffline,
}) async {
  final accessF = accessRepo.resolveAccess();
  final learningAccessF = configRepo.loadLearningAccess();
  final s = section;
  final hadCache = switch (s) {
    LearningSection.exams => await examRepo.hasSubjectsCache(ExamCategory.national),
    LearningSection.epreuves => await examRepo.hasSubjectsCache(ExamCategory.epreuve),
    LearningSection.mockExams => await examRepo.hasSubjectsCache(ExamCategory.mock),
    _ => await catalogRepo.hasSubjectsCacheForCourses(),
  };
  final data = switch (s) {
    LearningSection.exams => await examRepo.subjects(ExamCategory.national),
    LearningSection.epreuves => await examRepo.subjects(ExamCategory.epreuve),
    LearningSection.mockExams => await examRepo.subjects(ExamCategory.mock),
    _ => await catalogRepo.subjectsForCourses(),
  };
  final access = await accessF;
  final learningAccess = await learningAccessF;
  if (isMounted()) {
    onDataLoaded(data, access, learningAccess);
  }
  if (data.isEmpty) {
    await warnOffline(hadCache: hadCache, label: 'les matières de ${section.label}');
  }
  for (final sub in data.take(8)) {
    unawaited(warmupService.warmBeforeOpenSubject(section, sub.id));
  }
}
