import 'dart:async';
import 'package:eduquest/features/gamification/data/gamification_repository.dart';
import 'package:eduquest/features/learning/data/chapter_content_repository.dart';
import 'package:eduquest/features/learning/domain/chapter_resource.dart';
import 'package:eduquest/features/learning/domain/learning_chapter.dart';
import 'package:eduquest/features/learning/domain/learning_quiz.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/learning/presentation/pages/chapter_course_page.dart';
import 'package:eduquest/features/learning/presentation/pages/chapter_media_page.dart';
import 'package:flutter/material.dart';

class ChapterNavigator {
  ChapterNavigator._();

  static Future<void> open({
    required BuildContext context,
    required LearningChapter chapter,
    required LearningSection section,
    required bool Function() isMounted,
    required void Function(String? id) onOpeningIdChanged,
  }) async {
    onOpeningIdChanged(chapter.id);
    try {
      final chapterRepo = ChapterContentRepository();
      final gamification = GamificationRepository();
      if (section == LearningSection.courses) {
        final loaded = await Future.wait([
          chapterRepo.resources(chapterId: chapter.id, type: 'pdf'),
          chapterRepo.resources(chapterId: chapter.id, type: 'exercise_set'),
          chapterRepo.resources(chapterId: chapter.id, type: 'summary'),
          chapterRepo.quizzes(chapter.id),
        ]).timeout(const Duration(milliseconds: 2200));
        if (!isMounted()) return;
        final summaries = loaded[0] as List<ChapterResource>;
        final exercises = loaded[1] as List<ChapterResource>;
        final corrections = loaded[2] as List<ChapterResource>;
        final quizzes = loaded[3] as List<LearningQuiz>;
        unawaited(gamification.claimQuestByCode('open_lesson'));
        // ignore: use_build_context_synchronously — guarded by isMounted() above
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChapterCoursePage(
              chapterId: chapter.id,
              chapterTitle: chapter.title,
              initialSummaries: summaries,
              initialExercises: exercises,
              initialCorrections: corrections,
              initialQuizzes: quizzes,
            ),
          ),
        );
        return;
      }
      final type = section == LearningSection.youtube ? 'youtube' : 'video';
      final items = await chapterRepo
          .resources(chapterId: chapter.id, type: type)
          .timeout(const Duration(milliseconds: 1800));
      if (!isMounted()) return;
      // ignore: use_build_context_synchronously — guarded by isMounted() above
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChapterMediaPage(
            chapterId: chapter.id,
            chapterTitle: chapter.title,
            type: type,
            initialItems: items,
          ),
        ),
      );
    } catch (_) {
      if (!isMounted()) return;
      final type = section == LearningSection.youtube ? 'youtube' : 'video';
      final isCourse = section == LearningSection.courses;
      // ignore: use_build_context_synchronously — guarded by isMounted() above
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => isCourse
              ? ChapterCoursePage(chapterId: chapter.id, chapterTitle: chapter.title)
              : ChapterMediaPage(
                  chapterId: chapter.id,
                  chapterTitle: chapter.title,
                  type: type,
                ),
        ),
      );
    } finally {
      if (isMounted()) onOpeningIdChanged(null);
    }
  }
}
