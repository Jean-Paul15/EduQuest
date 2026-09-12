import 'quiz_content_block.dart';

enum QuizMode { standard, orientation, adaptive }

/// Stratégie de tirage du pool en mode `adaptive` (§12.2 du .md).
enum PoolSelection { random, stratified }

/// Configuration d'une session de quiz.
class QuizSessionConfig {
  const QuizSessionConfig({
    this.mode = QuizMode.standard,
    this.timePerQuestionSeconds = 30,
    this.shuffleOptions = true,
    this.showFeedback = true,
    this.allowGoBack = false,
    this.passingScorePercent = 50,
    this.feedbackMode = FeedbackMode.immediate,
    this.showCorrectAnswer = true,
    this.showExplanation = true,
    this.allowSkip = true,
    this.editableUntilNext = false,
    this.partialCredit = false,
    this.penaltyPerWrong = 0.0,
    this.questionsPerSession,
    this.poolSelection = PoolSelection.random,
    this.noRepeatInSession = false,
  });

  final QuizMode mode;
  final int timePerQuestionSeconds;
  final bool shuffleOptions;
  final bool showFeedback;
  final bool allowGoBack;
  final int passingScorePercent;
  final FeedbackMode feedbackMode;
  final bool showCorrectAnswer;
  final bool showExplanation;
  final bool allowSkip;
  final bool editableUntilNext;
  final bool partialCredit;
  final double penaltyPerWrong;

  /// Nombre de questions à tirer du pool en mode `adaptive` (`null` = tout
  /// le pool disponible, hors questions exclues).
  final int? questionsPerSession;

  /// Stratégie de tirage du pool. `stratified` n'est pas encore implémenté
  /// (demanderait un champ `tags`/thème sur `QuizQuestion`, absent du
  /// domaine actuel) — retombe sur `random`, voir `QuizSessionController`.
  final PoolSelection poolSelection;

  /// Si `true`, l'hôte doit fournir les questions déjà vues lors d'une
  /// tentative précédente via `QuizSessionController.excludedQuestionIds` —
  /// le moteur ne persiste rien lui-même (architecture storage-agnostic).
  final bool noRepeatInSession;

  QuizSessionConfig copyWith({
    QuizMode? mode,
    int? timePerQuestionSeconds,
    bool? shuffleOptions,
    bool? showFeedback,
    bool? allowGoBack,
    int? passingScorePercent,
    FeedbackMode? feedbackMode,
    bool? showCorrectAnswer,
    bool? showExplanation,
    bool? allowSkip,
    bool? editableUntilNext,
    bool? partialCredit,
    double? penaltyPerWrong,
    int? questionsPerSession,
    PoolSelection? poolSelection,
    bool? noRepeatInSession,
  }) {
    return QuizSessionConfig(
      mode: mode ?? this.mode,
      timePerQuestionSeconds:
          timePerQuestionSeconds ?? this.timePerQuestionSeconds,
      shuffleOptions: shuffleOptions ?? this.shuffleOptions,
      showFeedback: showFeedback ?? this.showFeedback,
      allowGoBack: allowGoBack ?? this.allowGoBack,
      passingScorePercent: passingScorePercent ?? this.passingScorePercent,
      feedbackMode: feedbackMode ?? this.feedbackMode,
      showCorrectAnswer: showCorrectAnswer ?? this.showCorrectAnswer,
      showExplanation: showExplanation ?? this.showExplanation,
      allowSkip: allowSkip ?? this.allowSkip,
      editableUntilNext: editableUntilNext ?? this.editableUntilNext,
      partialCredit: partialCredit ?? this.partialCredit,
      penaltyPerWrong: penaltyPerWrong ?? this.penaltyPerWrong,
      questionsPerSession: questionsPerSession ?? this.questionsPerSession,
      poolSelection: poolSelection ?? this.poolSelection,
      noRepeatInSession: noRepeatInSession ?? this.noRepeatInSession,
    );
  }
}
