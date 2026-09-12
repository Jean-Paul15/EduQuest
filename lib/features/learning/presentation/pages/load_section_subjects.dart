import 'dart:async';
import 'package:eduquest/features/access/data/access_repository.dart' show AccessState;
import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/shared/sync/service_locator.dart';
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
  required AppConfigRepository configRepo,
  required LearningWarmupService warmupService,
  required bool Function() isMounted,
  required void Function(List<LearningSubject> items, AccessState access, Map<String, String> learningAccess) onDataLoaded,
  required Future<void> Function({required bool hadCache, required String label}) warnOffline,
}) async {
  final learningAccessF = configRepo.loadLearningAccess();
  final s = section;
  final results = await switch (s) {
    LearningSection.exams => Future.wait<dynamic>([
        examRepo.hasSubjectsCache(ExamCategory.national),
        examRepo.subjects(ExamCategory.national),
      ]),
    LearningSection.epreuves => Future.wait<dynamic>([
        examRepo.hasSubjectsCache(ExamCategory.epreuve),
        examRepo.subjects(ExamCategory.epreuve),
      ]),
    LearningSection.mockExams => Future.wait<dynamic>([
        examRepo.hasSubjectsCache(ExamCategory.mock),
        examRepo.subjects(ExamCategory.mock),
      ]),
    _ => Future.wait<dynamic>([
        catalogRepo.hasSubjectsCacheForCourses(),
        catalogRepo.subjectsForCourses(),
      ]),
  };
  final hadCache = results[0] as bool;
  final data = results[1] as List<LearningSubject>;
  final learningAccess = await learningAccessF;
  final access = ServiceLocator().accessRepo.lastKnownAccess;
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
