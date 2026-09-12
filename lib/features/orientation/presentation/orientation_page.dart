import 'package:eduquest/features/orientation/data/orientation_profile_builder.dart';
import 'package:eduquest/features/orientation/data/orientation_repository.dart';
import 'package:eduquest/features/orientation/domain/orientation_recommendation.dart';
import 'package:eduquest/features/orientation/domain/recommended_field.dart';
import 'package:eduquest/features/orientation/presentation/orientation_analyzing_view.dart';
import 'package:eduquest/features/orientation/presentation/orientation_intro_view.dart';
import 'package:eduquest/features/orientation/presentation/orientation_question_flow.dart';
import 'package:eduquest/features/orientation/presentation/result/result_view.dart';
import 'package:eduquest/features/orientation/presentation/widgets/quiz_exit_dialog.dart';
import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/features/user/domain/user_profile.dart';
import 'package:eduquest/shared/sync/service_locator.dart';
import 'package:eduquest/shared/sync/offline_view_state.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:flutter/material.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

class OrientationPage extends StatefulWidget {
  const OrientationPage({
    super.key,
    this.embedded = false,
    this.repository,
    this.profileRepository,
    this.offlineState,
  });
  final bool embedded;
  final OrientationRepository? repository;
  final UserProfileRepository? profileRepository;
  final OfflineViewState? offlineState;
  @override
  State<OrientationPage> createState() => _OrientationPageState();
}

class _OrientationPageState extends State<OrientationPage> {
  late final OrientationRepository _repo;
  late final UserProfileRepository _profileRepo;
  late final OfflineViewState _offline;
  QuizDefinition? _definition;
  QuizSessionSnapshot? _draft;
  QuizSessionController? _controller;
  UserProfile? _profile;
  OrientationRecommendation? _result;
  String? _loadError;
  bool _loading = true, _starting = false, _analyzing = false;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? OrientationRepository();
    _profileRepo = widget.profileRepository ?? UserProfileRepository();
    _offline = widget.offlineState ?? LocatorOfflineViewState(ServiceLocator().notifier);
    _offline.addListener(_onOfflineChanged);
    _load();
  }

  @override
  void dispose() {
    _offline.removeListener(_onOfflineChanged);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onOfflineChanged() async {
    if (!mounted) return;
    setState(() {});
    if (!_offline.isOffline && _definition == null && !_loading) {
      await _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final def = await _repo.activeQuestionnaire();
      final draft = await _repo.loadDraft();
      final profile = await _profileRepo.load();
      if (!mounted) return;
      setState(() {
        _definition = def;
        _draft = draft;
        _profile = profile;
        _loading = false;
      });
    } on OrientationUnavailable catch (e) {
      if (!mounted) return;
      setState(() {
        _definition = null;
        _loadError = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _definition = null;
        _loadError = 'Le questionnaire d’orientation n’a pas pu être chargé.';
        _loading = false;
      });
    }
  }

  Future<void> _start({required bool resume}) async {
    if (_definition == null || _starting) return;
    setState(() => _starting = true);
    _controller?.dispose();
    final controller = QuizSessionController(definition: _definition!);
    controller.addListener(() => mounted ? setState(() {}) : null);
    if (resume && _draft != null) {
      await controller.resumeFromSnapshot(_draft!);
    } else {
      controller.start();
      await _repo.clearDraft();
    }
    if (!mounted) return;
    setState(() {
      _controller = controller;
      _result = null;
      _starting = false;
    });
  }

  Future<void> _persistDraft() async {
    final controller = _controller;
    if (controller == null || controller.state == QuizSessionState.completed) {
      return;
    }
    await _repo.saveDraft(controller.snapshot());
  }

  Future<void> _advance() async {
    final controller = _controller;
    if (controller == null || !controller.locked) {
      ModernSnackbar.show(
        context,
        'Valide d’abord ta réponse.',
        success: false,
      );
      return;
    }
    final isLast =
        controller.currentIndex == controller.definition.totalQuestions - 1;
    if (isLast) {
      await controller.finish();
      final completedSnapshot = controller.snapshot();
      await _repo.saveDraft(completedSnapshot);
      final series = _profile?.serieCode ?? 'D';
      final built = OrientationProfileBuilder.build(
        result: controller.result!,
        answers: controller.answers,
        definition: controller.definition,
      );
      if (!mounted) return;
      setState(() => _analyzing = true);
      try {
        List<RecommendedField> fields;
        try {
          fields = await _repo.matchFields(
            profile: built.profile,
            constraints: built.constraints,
            seriesCode: series,
          );
        } catch (_) {
          fields = OrientationProfileBuilder.offlineFallback(built.profile);
        }
        final result = await _repo.analyzeCompleted(
          snapshot: completedSnapshot,
          profile: built.profile,
          constraints: built.constraints,
          fields: fields,
          seriesCode: series,
          questionnaireVersion: _repo.activeVersion ?? 'unknown',
          learner: {
            'name': _profile?.displayName,
            'level': _profile?.levelCode,
            'country': _profile?.countryCode,
          },
        );
        if (!mounted) return;
        setState(() {
          _analyzing = false;
          _result = result;
          _draft = null;
        });
      } on OrientationUnavailable catch (e) {
        if (!mounted) return;
        setState(() => _analyzing = false);
        ModernSnackbar.show(context, e.message, success: false);
      }
      return;
    }
    controller.next();
    await _persistDraft();
  }

  /// Le test (ou son analyse) occupe l'écran : le retour doit être confirmé.
  bool get _testInProgress =>
      _result == null && (_controller != null || _analyzing);

  /// Revient à l'écran de lancement (`_IntroView`) sans perdre la progression.
  Future<void> _exitToIntro() async {
    await _persistDraft();
    _controller?.dispose();
    final draft = await _repo.loadDraft();
    if (!mounted) return;
    setState(() {
      _controller = null;
      _analyzing = false;
      _draft = draft;
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(
            child: RuachLoader(size: 108, label: 'Préparation de l’orientation'),
          )
        : _offline.isOffline
        ? const EmptyState(
            title: 'Orientation indisponible hors ligne',
            subtitle: 'Reconnecte-toi pour charger ou reprendre le test.',
          )
        : _definition == null
        ? EmptyState(
            title: 'Orientation indisponible',
            subtitle:
                _loadError ?? 'Le test d’orientation n’a pas pu être chargé.',
          )
        : _analyzing
        ? OrientationAnalyzingView(onClose: _exitToIntro)
        : _result != null
        ? OrientationResultView(
            reco: _result!,
            onRestart: () => _start(resume: false),
          )
        : _controller == null
        ? OrientationIntroView(
            hasDraft: _draft != null,
            starting: _starting,
            profile: _profile,
            onStart: () => _start(resume: false),
            onResume: () => _start(resume: true),
          )
        : OrientationQuestionFlow(
            controller: _controller!,
            onAnswer: (a) {
              _controller?.answer(a);
              _persistDraft();
            },
            onNext: _advance,
            onExit: _confirmExit,
          );
    final guarded = PopScope(
      canPop: !_testInProgress,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: body,
    );
    if (widget.embedded) return guarded;
    return Scaffold(
      appBar: const RuachAppBar(title: 'Orientation', showBack: true),
      body: guarded,
    );
  }

  Future<void> _confirmExit() async {
    if (!_testInProgress) return;
    if (await showQuizExitDialog(context) && mounted) {
      if (widget.embedded) {
        await _exitToIntro();
      } else {
        await _exitToIntro();
        if (mounted) Navigator.of(context).maybePop();
      }
    }
  }
}

