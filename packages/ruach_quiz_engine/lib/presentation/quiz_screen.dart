import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'constants.dart';
import '../domain/quiz_content_block.dart';
import '../domain/quiz_question.dart';
import 'quiz_controller_interface.dart';
import 'progress_header.dart';
import 'question_card.dart';
import 'widgets/content_block_renderer.dart';
import 'widgets/feedback_banner.dart';
import 'widgets/quiz_bottom_bar.dart';
import 'quiz_icons.dart';
import 'quiz_result_screen.dart';
import '../data/scoring_helpers.dart';

/// Main quiz screen — Scaffold with progress, question, navigation, results.
class QuizScreen extends StatelessWidget {
  const QuizScreen({
    super.key,
    required this.controller,
    this.successColor,
    this.errorColor,
    this.celebrationWrapper,
    this.cacheManager,
  });
  final QuizControllerInterface controller;
  final Color? successColor;
  final Color? errorColor;

  /// Injecté par l'hôte : cache d'images partagé avec le reste de l'app
  /// (clé versionnée, TTL, purge communs). `null` = cache par défaut du
  /// package (comportement inchangé si l'hôte ne fournit rien).
  final CacheManager? cacheManager;

  /// Injecté par l'hôte (le package ne peut pas dépendre de ConfettiOverlay,
  /// dépendance circulaire) — enveloppe l'écran de résultat pour célébrer une
  /// réussite. [passed] indique si le quiz est réussi.
  final Widget Function(Widget resultScreen, bool passed)? celebrationWrapper;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      syncQuizColors(
        Theme.of(context).colorScheme,
        success: successColor,
        error: errorColor,
      );
      if (controller.state == QuizSessionState.completed) {
        final result = controller.result;
        if (result == null) return const SizedBox.shrink();
        final cfg = controller.definition.config;
        final resultScreen = QuizResultScreen(result: result,
            onRetry: controller.restart,
            onClose: () => Navigator.of(context).maybePop(),
            contentBadges: controller.definition.contentBadges,
            showCorrections: cfg.feedbackMode != FeedbackMode.never && cfg.showCorrectAnswer);
        return celebrationWrapper?.call(resultScreen, result.passed) ?? resultScreen;
      }
      if (!controller.hasCurrentQuestion) {
        return Scaffold(
          backgroundColor: ink900,
          appBar: _appBar(context),
          body: _loadErrorBody(context),
        );
      }
      final cfg = controller.definition.config;
      const choiceTypes = {
        QuestionType.singleChoice,
        QuestionType.trueFalse,
        QuestionType.multiChoice,
      };
      final showValidateStep =
          cfg.showFeedback &&
          cfg.feedbackMode == FeedbackMode.immediate &&
          choiceTypes.contains(controller.currentQuestion.type);
      return Scaffold(
        backgroundColor: ink900, appBar: _appBar(context),
        body: _body(),
        bottomNavigationBar: QuizBottomBar(
          controller: controller,
          showValidateStep: showValidateStep,
        ),
      );
    },
  );

  /// Affiché quand la session n'a aucune question jouable — jamais un écran
  /// vide silencieux (principe UX du projet : erreur = cause compréhensible
  /// + action possible).
  Widget _loadErrorBody(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(QuizIcons.close, color: cream700, size: 36),
          const SizedBox(height: 16),
          Text(
            "Ce quiz n'a pas pu être chargé.",
            textAlign: TextAlign.center,
            style: TextStyle(color: cream900, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.restart,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    ),
  );

  AppBar _appBar(BuildContext context) => AppBar(
    backgroundColor: ink800,
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
    titleSpacing: 8,
    leadingWidth: 56,
    title: Text(
      controller.definition.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: cream900,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
    leading: IconButton(
      icon: Icon(QuizIcons.closeBold, color: cream700, size: 20),
      onPressed: () => Navigator.of(context).maybePop(),
    ),
  );

  Widget _body() {
    final cfg = controller.definition.config;
    // L'expiration du temps est un état système (jamais gouverné par feedbackMode) :
    // affichée même si le mode n'est pas "immediate", car ce n'est pas une correction.
    final showTimeout = controller.locked && controller.timedOut;
    // "Passer" verrouille la question sans réponse (comme un timeout, même
    // mécanisme `_lockCurrentTurn`) — sans ce cas à part, la question passée
    // tombait dans la branche "gradable" ci-dessous avec `selectedAnswer ==
    // null`, ce qui affichait une bannière "incorrect" alors que l'élève n'a
    // simplement rien répondu. Comme le timeout, c'est un état système,
    // jamais gouverné par feedbackMode : ce n'est pas une correction.
    final showSkipped = !showTimeout && controller.locked &&
        controller.selectedAnswer == null;
    final showFb = !showTimeout && !showSkipped && controller.locked &&
        cfg.showFeedback && cfg.feedbackMode == FeedbackMode.immediate;
    return Column(children: [
      ProgressHeader(
        currentIndex: controller.currentIndex,
        totalQuestions: controller.totalQuestions,
        secondsLeft: controller.secondsLeft,
        totalSeconds: controller.totalSeconds,
      ),
      // Le média/contexte partagé du groupe reste épinglé (hors scroll) —
      // §2.4/§2.5 du RUACHEDU_QUIZ_ENGINE.md : l'élève ne doit pas avoir à
      // remonter pour revoir le schéma/texte commun à chaque question.
      _buildGroupHeader(),
      Expanded(child: SingleChildScrollView(
          child: Column(children: [
        QuestionCard(
          question: controller.currentQuestion,
          locked: controller.locked,
          editable: controller.editable,
          selectedAnswer: controller.selectedAnswer,
          onAnswer: (a) => controller.answer(a),
          cacheManager: cacheManager,
          onImageLoadFailed: (url) => controller.analytics
              .trackImageLoadFailed(controller.definition.id, url),
          // "Valider" n'a d'interet que si le feedback immediat est actif
          // pour ce quiz (sinon il ne se passerait rien de visible) --
          // sans ca, la selection soumet directement au tap.
          requireValidation:
              cfg.showFeedback && cfg.feedbackMode == FeedbackMode.immediate,
          onDraft: (a) => controller.setDraftAnswer(a),
        ),
        if (showTimeout)
          const FeedbackBanner(
            correct: false,
            neutral: true,
            neutralMessage: 'Temps écoulé, passons à la suite',
          ),
        if (showSkipped)
          const FeedbackBanner(
            correct: false,
            neutral: true,
            neutralMessage: 'Question passée',
          ),
        if (showFb && !ScoringHelpers.isGradable(controller.currentQuestion.type))
          FeedbackBanner(
            correct: false,
            neutral: true,
            neutralMessage: 'Réponse enregistrée',
            explanation: cfg.showExplanation
                ? controller.currentQuestion.explanation
                : const [],
          ),
        if (showFb && ScoringHelpers.isGradable(controller.currentQuestion.type))
          FeedbackBanner(
            correct: controller.selectedAnswer != null &&
                ScoringHelpers.isCorrect(
                    controller.currentQuestion, controller.selectedAnswer!),
            explanation: cfg.showExplanation
                ? controller.currentQuestion.explanation
                : const [],
            showAnswer: cfg.showCorrectAnswer,
            correctAnswer: cfg.showCorrectAnswer
                ? ScoringHelpers.correctAnswerString(controller.currentQuestion)
                : null,
          ),
      ]))),
    ]);
  }

  Widget _buildGroupHeader() {
    final group = controller.definition.groupFor(
        controller.currentQuestion.id);
    if (group == null) return const SizedBox.shrink();
    return Column(children: [
      if (group.sharedMedia != null)
        ContentBlockRenderer(
          blocks: [group.sharedMedia!],
          cacheManager: cacheManager,
          onImageLoadFailed: (url) => controller.analytics
              .trackImageLoadFailed(controller.definition.id, url),
        ),
      if (group.title != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(group.title!,
              style: TextStyle(color: gold500, fontSize: 13,
                  fontWeight: FontWeight.w600))),
      if (group.sharedContext.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ContentBlockRenderer(
            blocks: group.sharedContext,
            cacheManager: cacheManager,
            onImageLoadFailed: (url) => controller.analytics
                .trackImageLoadFailed(controller.definition.id, url),
          )),
      Divider(color: cream200, height: 1),
    ]);
  }
}
