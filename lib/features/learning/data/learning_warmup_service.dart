import 'package:eduquest/features/learning/data/exam_repository.dart';
import 'package:eduquest/features/learning/data/chapter_content_repository.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/domain/exam_category.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';

class LearningWarmupService {
  final _catalog = LearningCatalogRepository();
  final _exams = ExamRepository();
  final _chapter = ChapterContentRepository();
  final Map<String, Future<void>> _pending = {};

  Future<void> warmSection(LearningSection section) =>
      _run('sec:${section.name}', () async {
        if (section == LearningSection.courses ||
            section == LearningSection.videos ||
            section == LearningSection.youtube) {
          await _catalog.subjectsForCourses();
          return;
        }
        if (section == LearningSection.exams) {
          await _exams.subjects(ExamCategory.national);
          return;
        }
        if (section == LearningSection.epreuves) {
          await _exams.subjects(ExamCategory.epreuve);
          return;
        }
        await _exams.subjects(ExamCategory.mock);
      });

  Future<void> warmBeforeOpenSubject(
    LearningSection section,
    String subjectId,
  ) => _run('sub:${section.name}:$subjectId', () async {
    if (section == LearningSection.courses ||
        section == LearningSection.videos ||
        section == LearningSection.youtube) {
      final chapters = await _catalog.chaptersBySubject(subjectId);
      if (chapters.isEmpty) return;
      final c = chapters.first.id;
      if (section == LearningSection.courses) {
        await Future.wait([
          _chapter.resources(chapterId: c, type: 'pdf'),
          _chapter.resources(chapterId: c, type: 'exercise_set'),
          _chapter.resources(chapterId: c, type: 'summary'),
          _chapter.quizzes(c),
        ]);
        return;
      }
      final t = section == LearningSection.youtube ? 'youtube' : 'video';
      await _chapter.resources(chapterId: c, type: t);
      return;
    }
    if (section == LearningSection.exams) {
      await _exams.listBySubject(
        subjectId: subjectId,
        category: ExamCategory.national,
      );
      return;
    }
    if (section == LearningSection.epreuves) {
      await _exams.listBySubject(
        subjectId: subjectId,
        category: ExamCategory.epreuve,
      );
      return;
    }
    await _exams.listBySubject(
      subjectId: subjectId,
      category: ExamCategory.mock,
    );
  });

  Future<void> _run(String key, Future<void> Function() task) {
    final running = _pending[key];
    if (running != null) return running;
    final f = task()
        .catchError((_) {})
        .whenComplete(() => _pending.remove(key));
    _pending[key] = f;
    return f;
  }
}
