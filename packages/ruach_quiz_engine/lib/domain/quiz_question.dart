import 'quiz_content_block.dart';

/// Types de questions supportés par le moteur de quiz.
enum QuestionType {
  singleChoice,
  multiChoice,
  trueFalse,
  scale,
  fillBlank,
  fillBlanks,
  cloze,
  matching,
  shortAnswer,
}

/// Label français pour chaque type (badge UI).
String questionTypeLabel(QuestionType t) => switch (t) {
  QuestionType.singleChoice => 'Choix unique',
  QuestionType.multiChoice => 'Choix multiple',
  QuestionType.trueFalse => 'Vrai / Faux',
  QuestionType.scale => 'Échelle',
  QuestionType.fillBlank => 'Texte à trous',
  QuestionType.fillBlanks => 'Trous multiples',
  QuestionType.cloze => 'Texte à compléter',
  QuestionType.matching => 'Association',
  QuestionType.shortAnswer => 'Réponse libre',
};

/// Entité représentant une question dans un quiz.
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.type,
    this.statement = const [],
    this.mediaAbove,
    this.prompt = '',
    required this.answerKey,
    this.explanation = const [],
    this.points = 1,
    this.context,
    this.groupId,
    this.difficultyLevel,
  });

  final String id;
  final QuestionType type;
  final List<ContentBlock> statement;
  final ContentBlock? mediaAbove;
  final String prompt;
  final Map<String, dynamic> answerKey;
  final List<ContentBlock> explanation;
  final int points;
  final String? context;
  final String? groupId; // null si hors-groupe

  /// Difficulté calibrée côté serveur (échelle Elo, voir `EloLite`) à partir
  /// des vraies réponses des élèves (`app_events: quiz_question_answered`).
  /// `null` = pas encore assez de réponses pour calibrer — le moteur retombe
  /// alors sur `EloLite.difficultyFromPoints` (voir `ability_rating.dart`).
  final double? difficultyLevel;

  /// Texte d'affichage : Content Blocks si présents, sinon prompt brut.
  String get displayText =>
      prompt.isNotEmpty ? prompt : _blocksToText(statement);

  String _blocksToText(List<ContentBlock> blocks) =>
      blocks.whereType<TextBlock>().map((b) => b.value).join(' ');

  /// Déduit le [QuestionType] depuis une chaîne de la DB.
  static QuestionType typeFromString(String raw) {
    return switch (raw) {
      'single_choice' || 'mcq' => QuestionType.singleChoice,
      'multi_choice' => QuestionType.multiChoice,
      'true_false' => QuestionType.trueFalse,
      'scale' => QuestionType.scale,
      'fill_blank' => QuestionType.fillBlank,
      'fill_blanks' => QuestionType.fillBlanks,
      'cloze' => QuestionType.cloze,
      'matching' => QuestionType.matching,
      'short' || 'short_answer' => QuestionType.shortAnswer,
      _ => QuestionType.singleChoice,
    };
  }
}
