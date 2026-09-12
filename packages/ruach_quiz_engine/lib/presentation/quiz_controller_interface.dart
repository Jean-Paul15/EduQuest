import 'package:flutter/material.dart';
import '../domain/quiz_definition.dart';
import '../domain/quiz_question.dart';
import '../domain/quiz_answer.dart';
import '../domain/quiz_result.dart';
import '../data/quiz_analytics_interface.dart';

enum QuizSessionState { idle, loading, active, reviewing, completed }

/// Interface that the real controller (Batch 4) will implement.
abstract class QuizControllerInterface extends ChangeNotifier {
  QuizDefinition get definition;
  QuizAnalyticsInterface get analytics;

  /// Nombre réel de questions de CETTE session — à privilégier sur
  /// `definition.totalQuestions` pour l'affichage (barre de progression) :
  /// en mode adaptatif, tient compte des exclusions runtime
  /// (`excludedQuestionIds`, no-repeat-in-session) que `definition` seule
  /// ne peut pas connaître.
  int get totalQuestions;
  int get currentIndex;

  /// `false` si la session n'a aucune question jouable à l'index courant
  /// (liste vide, désynchronisation entre `currentIndex` et le contenu
  /// réellement chargé) — l'UI doit vérifier ce champ avant de lire
  /// [currentQuestion], qui lève sinon une erreur.
  bool get hasCurrentQuestion;
  QuizQuestion get currentQuestion;
  int get secondsLeft;
  int get totalSeconds;
  QuizAnswer? get selectedAnswer;

  /// Réponse en cours de sélection, pas encore soumise — alimentée par les
  /// renderers à choix (single/true-false/multi) quand un "Valider" explicite
  /// est requis (feedback immédiat configuré), pour que le bouton unique de
  /// [QuizBottomBar] (Valider → Continuer) sache quoi soumettre. `null` tant
  /// que rien n'est sélectionné, ou pour les types de question qui soumettent
  /// directement (pas de palier "Valider" distinct).
  QuizAnswer? get draftAnswer;
  void setDraftAnswer(QuizAnswer? a);
  Map<String, QuizAnswer> get answers;
  Map<String, int> get timeSpentPerQuestion;
  QuizResult? get result;
  QuizSessionState get state;
  bool get locked;
  bool get editable;
  bool get canSkip;
  bool get timedOut;
  void answer(QuizAnswer a);
  void skip();
  void next();
  void restart();
  Future<void> finish();
}
