import 'package:eduquest/features/learning/presentation/pages/chapter_quiz_list_page.dart';
import 'package:eduquest/features/learning/presentation/pages/chapter_resource_list_page.dart';
import 'package:eduquest/features/learning/domain/chapter_resource.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_tab_bar.dart';
import 'package:flutter/material.dart';

class ChapterCoursePage extends StatelessWidget {
  const ChapterCoursePage({
    super.key,
    required this.chapterId,
    required this.chapterTitle,
    this.initialSummaries,
    this.initialExercises,
    this.initialCorrections,
    this.initialQuizzes,
  });
  final String chapterId;
  final String chapterTitle;
  final List<ChapterResource>? initialSummaries;
  final List<ChapterResource>? initialExercises;
  final List<ChapterResource>? initialCorrections;
  final List<QuizSummary>? initialQuizzes;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
          appBar: RuachAppBar(
            title: chapterTitle,
            showBack: true,
            bottom: const RuachTabBar(
              tabs: [
                Tab(text: 'Résumé'),
                Tab(text: 'Exercices'),
                Tab(text: 'Corrigés'),
                Tab(text: 'QCM'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ChapterResourceListPage(
                chapterId: chapterId,
                type: 'pdf',
                emptyLabel: 'Résumé non publié.',
                initialItems: initialSummaries,
              ),
              ChapterResourceListPage(
                chapterId: chapterId,
                type: 'exercise_set',
                emptyLabel: 'Exercices non publiés.',
                initialItems: initialExercises,
              ),
              ChapterResourceListPage(
                chapterId: chapterId,
                type: 'summary',
                emptyLabel: 'Corrigés non publiés.',
                initialItems: initialCorrections,
              ),
              ChapterQuizListPage(
                chapterId: chapterId,
                initialItems: initialQuizzes,
              ),
            ],
          ),
        ),
      );
  }
}
