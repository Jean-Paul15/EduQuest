import '../domain/quiz_definition.dart';
import '../domain/quiz_group.dart';
import '../domain/quiz_question.dart';
import 'content_block_parser.dart';
import 'qdl_parser_helpers.dart';

/// Parse le JSON QDL (Quiz Definition Language) en [QuizDefinition].
/// Accepte le format legacy (questions plates) et le format étendu.
class QdlParser {
  const QdlParser();

  /// Parse un JSON complet de type QDL wrapper.
  QuizDefinition parseFull(Map<String, dynamic> raw) {
    final quiz = raw['quiz'] as Map<String, dynamic>;
    return _parseQuizMap(quiz);
  }

  /// Parse une liste brute de questions (format DB actuel).
  QuizDefinition parseQuestions({
    required String quizId,
    required String title,
    required List<Map<String, dynamic>> rows,
    Map<String, dynamic>? configJson,
  }) {
    final questions = rows
        .map(QdlParserHelpers.parseLegacyQuestion)
        .where((q) => q != null)
        .cast<QuizQuestion>()
        .toList();
    return QuizDefinition(
      id: quizId,
      title: title,
      questions: questions,
      config: QdlParserHelpers.parseConfig(configJson),
    );
  }

  QuizDefinition _parseQuizMap(Map<String, dynamic> quiz) {
    final configJson = quiz['config'] as Map<String, dynamic>?;
    final questionsRaw = quiz['questions'] as List? ?? [];
    final questions = questionsRaw
        .map((e) => QdlParserHelpers.parseQuestion(e as Map<String, dynamic>))
        .toList();
    final poolRaw = quiz['questions_pool'] as List? ?? [];
    final pool = poolRaw
        .map((e) => QdlParserHelpers.parseQuestion(e as Map<String, dynamic>))
        .toList();
    final groupsRaw = quiz['groups'] as List? ?? [];
    final groups = groupsRaw.map((g) => _parseGroup(g as Map<String, dynamic>))
        .toList();
    return QuizDefinition(
      id: quiz['id'] as String,
      title: quiz['title'] as String,
      questions: questions,
      questionsPool: pool,
      groups: groups,
      config: QdlParserHelpers.parseConfig(configJson),
    );
  }

  QuestionGroup _parseGroup(Map<String, dynamic> g) {
    final media = g['shared_media'];
    return QuestionGroup(
      id: g['id'] as String,
      title: g['group_title'] as String?,
      sharedContext: ContentBlockParser.parseList(g['shared_context']),
      sharedMedia: media is Map
          ? ContentBlockParser.parse(Map<String, dynamic>.from(media))
          : null,
      layout: g['layout'] == 'all_visible' ? GroupLayout.allVisible
          : GroupLayout.sequential,
    );
  }
}
