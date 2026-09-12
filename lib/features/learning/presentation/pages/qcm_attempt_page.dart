import 'dart:async';
import 'dart:convert';
import 'package:eduquest/features/engagement/presentation/engagement_confirm_dialogs.dart';
import 'package:eduquest/features/gamification/data/gamification_repository.dart';
import 'package:eduquest/features/learning/data/learning_content_repository.dart';
import 'package:eduquest/features/learning/data/quiz_analytics.dart';
import 'package:eduquest/features/learning/data/local_quiz_result_repository.dart';
import 'package:eduquest/features/learning/data/quiz_attempts_repository.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/media/ruach_cache_manager.dart';
import 'package:eduquest/shared/security/sensitive_scope.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/offline_content_guard.dart';
import 'package:eduquest/shared/ui/ruach_confetti.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

/// Page de tentative de quiz. Delegue au package ruach_quiz_engine.
class QcmAttemptPage extends StatefulWidget {
  const QcmAttemptPage({
    super.key,
    required this.quizId,
    required this.title,
    this.repository,
    this.gamificationRepository,
    this.localCache,
    this.initialDefinition,
    this.initialSnapshot,
  });
  final String quizId;
  final String title;
  final LearningContentRepository? repository;
  final GamificationRepository? gamificationRepository;
  final LocalJsonCache? localCache;
  final QuizDefinition? initialDefinition;
  final QuizSessionSnapshot? initialSnapshot;
  @override
  State<QcmAttemptPage> createState() => _QcmAttemptPageState();
}

class _QcmAttemptPageState extends State<QcmAttemptPage>
    with WidgetsBindingObserver {
  late final LearningContentRepository _repo;
  late final GamificationRepository _gamification;
  late final LocalJsonCache _local;
  final _quizAttempts = QuizAttemptsRepository();
  QuizSessionController? _controller;
  Timer? _persistTimer;
  bool _loading = true;
  String? _error;
  bool _questClaimed = false;
  bool _offlineWarned = false;
  String? _lastPersistedPayload;
  int _lastPersistedIndex = -1;
  int _lastPersistedAnswerCount = -1;

  static const _abilityKey = 'ability:elo_lite';
  String get _sessionKey => 'session:quiz:${widget.quizId}';

  /// Habileté Elo-lite (§12.3) : lue/écrite en local uniquement, jamais
  /// envoyée au serveur — voir packages/ruach_quiz_engine/lib/data/ability_rating.dart.
  Future<double?> _loadAbility() async {
    final rows = await _local.readList(_abilityKey);
    final value = (rows != null && rows.isNotEmpty) ? rows.first['value'] : null;
    return value is num ? value.toDouble() : null;
  }

  Future<void> _saveAbility(double value) =>
      _local.writeList(_abilityKey, [{'value': value}]);
  QuizSessionController get _activeController => _controller!;
  bool get _hasActiveAttempt =>
      !_loading &&
      _error == null &&
      _controller?.state == QuizSessionState.active;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? LearningContentRepository();
    _gamification =
        widget.gamificationRepository ?? GamificationRepository();
    _local = widget.localCache ?? LocalJsonCache();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  Future<void> _load() async {
    try {
      if (widget.initialDefinition != null) {
        final controller = QuizSessionController(
          definition: widget.initialDefinition!,
          analytics: SupabaseQuizAnalytics(),
          initialAbility: await _loadAbility(),
          onAbilityChanged: (v) => unawaited(_saveAbility(v)),
        );
        if (widget.initialSnapshot != null) {
          await controller.resumeFromSnapshot(widget.initialSnapshot!);
        } else {
          controller.start();
        }
        controller.addListener(_onControllerChange);
        _controller = controller;
        if (mounted) setState(() => _loading = false);
        return;
      }
      final futures = await Future.wait<dynamic>([
        _repo.fetchQuizBundle(widget.quizId),
        _local.readList(_sessionKey),
      ]);
      if (!mounted) return;
      final bundle =
          futures[0]
              as ({
                String id,
                String title,
                Map<String, dynamic>? config,
                List<Map<String, dynamic>> groups,
                List<Map<String, dynamic>> questions,
                List<Map<String, dynamic>> questionsPool,
              });
      final snapshot = QuizSessionSnapshot.fromRows(
        futures[1] as List<Map<String, dynamic>>?,
      );
      if (bundle.questions.isEmpty && bundle.questionsPool.isEmpty) {
        throw StateError('empty-quiz');
      }
      final parser = const QdlParser();
      final finalDef = parser.parseFull({
        'quiz': {
          'id': bundle.id,
          'title': bundle.title.isNotEmpty ? bundle.title : widget.title,
          'config': bundle.config,
          'groups': bundle.groups,
          'questions': bundle.questions,
          'questions_pool': bundle.questionsPool,
        },
      });
      final controller = QuizSessionController(
        definition: finalDef,
        analytics: SupabaseQuizAnalytics(),
        initialAbility: await _loadAbility(),
        onAbilityChanged: (v) => unawaited(_saveAbility(v)),
      );
      if (snapshot != null) {
        await controller.resumeFromSnapshot(snapshot);
      } else {
        controller.start();
      }
      controller.addListener(_onControllerChange);
      _controller = controller;
      setState(() => _loading = false);
    } catch (_) {
      final hasCachedAssets = await _repo.hasQuizBundleCache(widget.quizId);
      if (!mounted) return;
      if (!hasCachedAssets && !_offlineWarned) {
        _offlineWarned = await guardOfflineContent(
          context: context,
          contentLabel: 'ce quiz',
        );
      }
      setState(() {
        _error = hasCachedAssets
            ? 'Impossible de charger ce quiz pour le moment.'
            : 'Ce quiz n\'est pas encore disponible hors ligne.';
        _loading = false;
      });
    }
  }

  void _onControllerChange() {
    final controller = _controller;
    if (controller == null) return;
    if (controller.state == QuizSessionState.completed &&
        controller.result != null) {
      _persistTimer?.cancel();
      unawaited(
        LocalQuizResultRepository().save(
          controller.result!,
          widget.quizId,
          widget.title,
        ),
      );
      unawaited(_quizAttempts.record(controller.result!, widget.quizId));
      unawaited(_local.removeByPrefix(_sessionKey));
      if (!_questClaimed) {
        _questClaimed = true;
        unawaited(_gamification.claimQuestByCode('complete_quiz'));
      }
      return;
    }
    if (controller.state != QuizSessionState.active) return;
    final indexChanged = controller.currentIndex != _lastPersistedIndex;
    final answerCountChanged =
        controller.answers.length != _lastPersistedAnswerCount;
    if (controller.locked || indexChanged || answerCountChanged) {
      unawaited(_persistSession());
      return;
    }
    _schedulePersist();
  }

  void _schedulePersist() {
    if (_persistTimer?.isActive ?? false) return;
    _persistTimer = Timer(const Duration(seconds: 4), () {
      _persistTimer = null;
      unawaited(_persistSession());
    });
  }

  Future<void> _persistSession() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      final snapshot = controller.snapshot();
      final payload = jsonEncode([snapshot.toMap()]);
      if (payload == _lastPersistedPayload) return;
      await _local.writeList(_sessionKey, [snapshot.toMap()]);
      _lastPersistedPayload = payload;
      _lastPersistedIndex = snapshot.currentIndex;
      _lastPersistedAnswerCount = snapshot.answers.length;
    } catch (_) {}
  }

  Future<void> _handleLeaveAttempt() async {
    final leave = await confirmEngagementAction(
      context,
      title: 'Quitter le quiz ?',
      message: 'La progression en cours est sauvegardée sur cet appareil.',
      confirmLabel: 'Quitter',
      cancelLabel: 'Rester',
    );
    if (leave && mounted) {
      await _persistSession();
      if (!mounted) return;
      // Navigator.pop() (pas maybePop) : après confirmation explicite, on
      // doit forcer la sortie — maybePop revérifierait PopScope.canPop
      // (toujours false ici tant que le quiz est actif) et annulerait le pop.
      Navigator.of(context).pop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_hasActiveAttempt) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      unawaited(_persistSession());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _persistTimer?.cancel();
    if (_hasActiveAttempt) {
      unawaited(_persistSession());
    }
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_onControllerChange);
    }
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SensitiveScope(
        child: Scaffold(
          appBar: RuachAppBar(title: widget.title, showBack: true),
          body: ListView(
            padding: const EdgeInsets.all(RuachSpace.s4),
            children: const [
              RuachCardSkeleton(),
              SizedBox(height: RuachSpace.s3),
              RuachCardSkeleton(),
            ],
          ),
        ),
      );
    }
    if (_error != null) {
      return SensitiveScope(
        child: Scaffold(
          appBar: RuachAppBar(title: widget.title, showBack: true),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(RuachSpace.s4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EmptyState(
                    title: 'Quiz indisponible',
                    subtitle: _error!,
                    icon: PhosphorIconsRegular.warningCircle,
                  ),
                  const SizedBox(height: RuachSpace.s4),
                  RuachButton(
                    label: 'Réessayer',
                    icon: PhosphorIconsRegular.arrowsClockwise,
                    onPressed: () {
                      setState(() {
                        _loading = true;
                        _error = null;
                      });
                      _load();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return SensitiveScope(
      // Sans ce ListenableBuilder, `canPop` restait figé sur la valeur calculée
      // au dernier build de la page (quiz actif → false). En fin de quiz la page
      // ne se reconstruit pas, donc la croix et « Terminer » de l'écran Résultat
      // — qui appellent maybePop() — étaient bloquées par un PopScope périmé.
      child: ListenableBuilder(
        listenable: _activeController,
        builder: (context, _) => PopScope(
          canPop: !_hasActiveAttempt,
          onPopInvokedWithResult: (didPop, _) async {
            if (!didPop && _hasActiveAttempt) await _handleLeaveAttempt();
          },
          child: QuizScreen(
            controller: _activeController,
            successColor: RuachColors.success600,
            errorColor: RuachColors.error400,
            celebrationWrapper: (result, passed) =>
                ConfettiOverlay(active: passed, child: result),
            cacheManager: RuachCacheManager.instance,
          ),
        ),
      ),
    );
  }
}
