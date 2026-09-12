import '../domain/quiz_answer.dart';
import '../domain/quiz_definition.dart';
import '../domain/quiz_question.dart';
import '../domain/quiz_result.dart';
import '../presentation/quiz_controller_interface.dart';
import 'ability_rating.dart';
import 'quiz_analytics_interface.dart';
import 'quiz_session_snapshot.dart';
import 'scoring_engine.dart';
import 'scoring_helpers.dart';
import 'session_timer.dart';

class QuizSessionController extends QuizControllerInterface {
  QuizSessionController({
    required this.definition,
    this.analytics = const NoOpAnalytics(),
    double? initialAbility,
    this.onAbilityChanged,
    this.excludedQuestionIds = const {},
    this.onQuestionsDrawn,
  }) : ability = initialAbility ?? EloLite.defaultAbility;
  @override
  final QuizDefinition definition;
  @override
  final QuizAnalyticsInterface analytics;

  /// Callback appelé après chaque réponse notée avec la nouvelle habileté
  /// Elo-lite (§12.3) — l'hôte décide où la persister (aucune dépendance
  /// de stockage dans le package).
  final void Function(double newAbility)? onAbilityChanged;
  final _elo = const EloLite();

  /// Habileté courante de l'élève (Elo-lite), sur cette session.
  double ability;

  /// Questions du pool à exclure du tirage (`config.noRepeatInSession`,
  /// §12.2) — l'hôte fournit l'historique, le moteur ne persiste rien
  /// lui-même (architecture storage-agnostic, comme `initialAbility`).
  final Set<String> excludedQuestionIds;

  /// Notifie l'hôte des IDs de questions tirées du pool, dans l'ordre de
  /// jeu — pour que l'hôte puisse persister l'historique s'il le souhaite.
  final void Function(List<String> questionIds)? onQuestionsDrawn;

  final _s = const ScoringEngine();
  final _answers = <String, QuizAnswer>{};
  final _spent = <String, int>{};
  final _timer = SessionTimer();
  final List<QuizQuestion> _played = [];
  final List<QuizQuestion> _pool = [];
  int _totalToPlay = 0;
  QuizSessionState _state = QuizSessionState.idle;
  int _currentIndex = 0, _secondsLeft = 30, _totalSeconds = 0;
  QuizAnswer? _selectedAnswer;
  QuizAnswer? _draftAnswer;
  QuizResult? _result;
  bool _locked = false;
  bool _timedOut = false;

  @override
  QuizSessionState get state => _state;
  @override
  int get currentIndex => _currentIndex;
  @override
  int get secondsLeft => _secondsLeft;
  @override
  int get totalSeconds => _totalSeconds;
  @override
  QuizAnswer? get selectedAnswer => _selectedAnswer;
  @override
  QuizAnswer? get draftAnswer => _draftAnswer;
  @override
  void setDraftAnswer(QuizAnswer? a) {
    if (_locked && !editable) return;
    _draftAnswer = a;
    notifyListeners();
  }
  @override
  Map<String, QuizAnswer> get answers => Map.unmodifiable(_answers);
  @override
  Map<String, int> get timeSpentPerQuestion => Map.unmodifiable(_spent);
  @override
  QuizResult? get result => _result;
  @override
  bool get locked => _locked;
  @override
  bool get timedOut => _timedOut;
  @override
  bool get editable => definition.config.editableUntilNext;
  @override
  bool get canSkip => definition.config.allowSkip && !_locked;
  @override
  int get totalQuestions => _totalToPlay;

  void start() {
    _state = QuizSessionState.active;
    _currentIndex = 0;
    _answers.clear();
    _spent.clear();
    _result = null;
    _totalSeconds = 0;
    _played.clear();
    _pool.clear();
    if (definition.isAdaptivePool) {
      _pool.addAll(_initialPool(excludedQuestionIds));
      // Le cap réel dépend du pool APRÈS exclusions (excludedQuestionIds),
      // jamais de definition.questionsPool.length brut — sinon next() peut
      // tenter de tirer une question d'un pool déjà vide.
      _totalToPlay = (definition.config.questionsPerSession ?? _pool.length)
          .clamp(0, _pool.length);
      _drawIfNeeded();
    } else {
      _playFixedList();
    }
    onQuestionsDrawn?.call(_played.map((q) => q.id).toList(growable: false));
    analytics.trackQuizStarted(definition.id, definition.title, _totalToPlay);
    _startTurn();
    notifyListeners();
  }

  @override
  void answer(QuizAnswer a) {
    if (_locked && !editable) return;
    _timer.cancel();
    _answers[a.questionId] = a;
    _spent[a.questionId] =
        definition.config.timePerQuestionSeconds - _secondsLeft;
    _selectedAnswer = a;
    _draftAnswer = null;
    _locked = true;
    final correct = ScoringHelpers.isCorrect(_q, a);
    if (ScoringHelpers.isGradable(_q.type)) {
      ability = _elo.updateAbility(ability, _difficultyOf(_q), correct);
      onAbilityChanged?.call(ability);
    }
    analytics.trackQuestionAnswered(
      definition.id,
      _q.id,
      _q.type,
      correct,
      _spent[a.questionId]!,
    );
    notifyListeners();
  }

  @override
  void skip() {
    if (_locked || !definition.config.allowSkip) return;
    _timedOut = false;
    _lockCurrentTurn();
  }

  void _onTimeExpired() {
    if (_locked) return;
    _timedOut = true;
    _lockCurrentTurn();
  }

  void _lockCurrentTurn() {
    _spent[_q.id] = definition.config.timePerQuestionSeconds - _secondsLeft;
    _timer.cancel();
    _locked = true;
    _selectedAnswer = null;
    _draftAnswer = null;
    analytics.trackQuestionSkipped(definition.id, _q.id);
    notifyListeners();
  }

  @override
  void next() {
    if (_currentIndex + 1 >= _totalToPlay) return;
    _currentIndex++;
    if (_drawIfNeeded()) {
      onQuestionsDrawn?.call(_played.map((q) => q.id).toList(growable: false));
    }
    _startTurn();
  }

  QuizSessionSnapshot snapshot() {
    final spent = Map<String, int>.from(_spent);
    if (_state == QuizSessionState.active) {
      final liveSpent =
          definition.config.timePerQuestionSeconds - _secondsLeft;
      final currentSpent = liveSpent.clamp(
        0,
        definition.config.timePerQuestionSeconds,
      );
      final previous = spent[_q.id] ?? 0;
      spent[_q.id] = currentSpent > previous ? currentSpent : previous;
    }
    return QuizSessionSnapshot(
      currentIndex: _currentIndex,
      answers: Map.unmodifiable(_answers),
      spent: Map.unmodifiable(spent),
      currentLocked: _locked,
    );
  }

  /// Restaure une session interrompue.
  ///
  /// Cas adaptatif : les questions déjà répondues sont restaurées dans leur
  /// ordre de jeu d'origine (préservé par l'ordre d'insertion de [answers]),
  /// puis le pool restant est reconstitué (moins l'historique + les IDs déjà
  /// répondus) pour retirer la ou les questions manquantes jusqu'à
  /// `currentIndex`. Le tirage exact d'avant une interruption n'est donc pas
  /// garanti identique si l'habileté a changé entre-temps — dégradation
  /// acceptée, jamais de crash, jamais de question dupliquée.
  Future<void> resumeSession({
    required int currentIndex,
    required Map<String, QuizAnswer> answers,
    required Map<String, int> spent,
    bool currentLocked = false,
  }) async {
    _state = QuizSessionState.active;
    _answers
      ..clear()
      ..addAll(answers);
    _spent
      ..clear()
      ..addAll(spent);
    _result = null;
    _totalSeconds = _spent.values.fold(0, (a, b) => a + b);
    _played.clear();
    _pool.clear();
    if (definition.isAdaptivePool) {
      _played.addAll(
        answers.keys.map(_findInPool).whereType<QuizQuestion>(),
      );
      final excluded = {...excludedQuestionIds, ...answers.keys};
      _pool.addAll(_initialPool(excluded));
      _totalToPlay = (definition.config.questionsPerSession ??
              (_played.length + _pool.length))
          .clamp(0, _played.length + _pool.length);
      while (_played.length <= currentIndex && _drawIfNeeded()) {}
    } else {
      _playFixedList();
    }
    _currentIndex = _totalToPlay == 0 ? 0 : currentIndex.clamp(0, _totalToPlay - 1);
    _restoreTurn(currentLocked: currentLocked);
    notifyListeners();
  }

  Future<void> resumeFromSnapshot(QuizSessionSnapshot snapshot) {
    return resumeSession(
      currentIndex: snapshot.currentIndex,
      answers: snapshot.answers,
      spent: snapshot.spent,
      currentLocked: snapshot.currentLocked,
    );
  }

  @override
  Future<void> finish() async {
    _timer.cancel();
    final qid = _q.id;
    _spent.putIfAbsent(
      qid,
      () => definition.config.timePerQuestionSeconds - _secondsLeft,
    );
    _state = QuizSessionState.completed;
    _result = _s.score(definition, _played, _answers, _spent);
    final canonicalTime = _result!.totalTimeSeconds;
    analytics.trackQuizCompleted(
      definition.id,
      _result!.scorePercent,
      _result!.passed,
      canonicalTime,
      _result!.correctCount,
      _result!.totalQuestions,
    );
    notifyListeners();
  }

  @override
  void restart() {
    _answers.clear();
    _spent.clear();
    _result = null;
    _selectedAnswer = null;
    _draftAnswer = null;
    _currentIndex = 0;
    _totalSeconds = 0;
    start();
  }

  @override
  void dispose() {
    if (_state == QuizSessionState.active) {
      analytics.trackQuizAbandoned(definition.id, _currentIndex, _totalSeconds);
    }
    _timer.cancel();
    super.dispose();
  }

  @override
  bool get hasCurrentQuestion =>
      _currentIndex >= 0 && _currentIndex < _played.length;
  QuizQuestion get _q => _played[_currentIndex];
  @override
  QuizQuestion get currentQuestion => _q;

  /// Difficulté calibrée si disponible (§1, serveur), sinon fallback par
  /// barème de points (`EloLite.difficultyFromPoints`) — jamais de rupture
  /// pour une question pas encore assez répondue pour être calibrée.
  double _difficultyOf(QuizQuestion q) =>
      q.difficultyLevel ?? EloLite.difficultyFromPoints(q.points);

  /// Liste fixe (mode standard/orientation) : jouée telle quelle, pas de
  /// tirage — partagé entre `start()` et `resumeSession()`.
  ///
  /// Filet de sécurité : si `questions` est vide mais que `questionsPool` a
  /// du contenu (backend ayant classé les questions comme "pool" alors que
  /// le mode reste non-adaptatif — désynchronisation classification/mode),
  /// on joue quand même le pool comme liste fixe plutôt que de démarrer une
  /// session sans aucune question.
  void _playFixedList() {
    _played.addAll(
      definition.questions.isNotEmpty
          ? definition.questions
          : definition.questionsPool,
    );
    _totalToPlay = _played.length;
  }

  /// Tire une question de plus si la session n'a pas encore atteint son
  /// quota et qu'il en reste dans le pool. Retourne `true` si une question a
  /// été tirée — partagé entre `start()`, `next()` et `resumeSession()`
  /// (cette dernière l'appelle en boucle pour rattraper `currentIndex`).
  bool _drawIfNeeded() {
    if (_played.length >= _totalToPlay || _pool.isEmpty) return false;
    _played.add(_drawNext());
    return true;
  }

  List<QuizQuestion> _initialPool(Set<String> excluded) {
    final available = definition.questionsPool
        .where((q) => !excluded.contains(q.id))
        .toList();
    // `stratified` (§12.2) demanderait un champ thème/tag sur QuizQuestion,
    // absent du domaine actuel — retombe sur un ordre aléatoire plutôt que
    // de simuler une stratification qui n'existerait pas réellement.
    available.shuffle();
    return available;
  }

  /// Tire dans `_pool` la question la plus proche de l'habileté courante —
  /// approche CAT (computerized adaptive testing) continue, plus précise
  /// qu'une progression par paliers discrets 1-5 et cohérente avec l'Elo-lite
  /// déjà en place (divergence assumée par rapport à la règle figée
  /// initialement documentée en §12.3). Scan linéaire + swap-remove (O(N))
  /// plutôt qu'un tri complet (O(N log N)) — seul le meilleur candidat
  /// compte, l'ordre du reste du pool n'a jamais d'importance.
  QuizQuestion _drawNext() {
    var bestIndex = 0;
    var bestDistance = (_difficultyOf(_pool[0]) - ability).abs();
    for (var i = 1; i < _pool.length; i++) {
      final distance = (_difficultyOf(_pool[i]) - ability).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    final picked = _pool[bestIndex];
    _pool[bestIndex] = _pool.last;
    _pool.removeLast();
    return picked;
  }

  QuizQuestion? _findInPool(String id) {
    for (final q in definition.questionsPool) {
      if (q.id == id) return q;
    }
    return null;
  }

  void _startTurn() {
    _locked = false;
    _timedOut = false;
    _selectedAnswer = _answers[_q.id];
    _draftAnswer = null;
    _secondsLeft = definition.config.timePerQuestionSeconds;
    _armTimer();
    notifyListeners();
  }

  void _restoreTurn({bool currentLocked = false}) {
    _timer.cancel();
    _timedOut = false;
    _selectedAnswer = _answers[_q.id];
    _draftAnswer = null;
    _locked = _selectedAnswer != null || currentLocked;
    final spent = (_spent[_q.id] ?? 0).clamp(
      0,
      definition.config.timePerQuestionSeconds,
    );
    _secondsLeft = definition.config.timePerQuestionSeconds - spent;
    if (!_locked) _armTimer();
  }

  /// Démarre le minuteur de la question courante — partagé entre
  /// `_startTurn` et `_restoreTurn` (jusqu'ici deux closures identiques).
  void _armTimer() {
    _timer.cancel();
    _timer.start(
      fromSeconds: _secondsLeft,
      onTick: (r) {
        _secondsLeft = r;
        _totalSeconds++;
        notifyListeners();
      },
      onTimeout: _onTimeExpired,
    );
  }
}
