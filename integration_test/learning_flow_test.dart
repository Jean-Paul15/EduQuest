import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/features/learning/presentation/pages/chapter_list_page.dart';
import 'package:eduquest/features/learning/presentation/pages/qcm_attempt_page.dart';
import 'package:eduquest/features/learning/presentation/pages/subject_section_page.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/test_data.dart';
import 'support/test_harness.dart';

void main() {
  testWidgets('learning:subjects-and-chapters render without spinner loop', (tester) async {
    await pumpTestApp(
      tester,
      SubjectSectionPage(
        section: LearningSection.courses,
        loader: () async => (
          items: testSubjects,
          access: const AccessState(tier: 'FULL', hasAccess: true, expiresAt: null),
          learningAccess: const {'courses': 'FULL'},
          seriesMissing: false,
        ),
      ),
    );
    expect(find.text('Mathématiques'), findsOneWidget);
    await pumpTestApp(
      tester,
      ChapterListPage(
        subjectId: 'math',
        subjectLabel: 'Mathématiques',
        section: LearningSection.courses,
        loader: () async => (items: testChapters, seriesBlocked: false),
      ),
    );
    expect(find.text('Fonctions'), findsOneWidget);
  });

  testWidgets('learning:quiz-launch opens a real quiz screen', (tester) async {
    await pumpTestApp(
      tester,
      QcmAttemptPage(
        quizId: 'quiz-1',
        title: 'QCM de test',
        initialDefinition: buildQuizDefinition(),
      ),
    );
    expect(find.text('Combien font 2 + 2 ?'), findsOneWidget);
    await tester.tap(find.text('4'));
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();
    expect(find.text('Bonne réponse !'), findsOneWidget);
  });
}
