import 'dart:async';

import 'package:eduquest/features/assistant/data/ai_assistant_repository.dart';
import 'package:eduquest/features/assistant/data/image_picker_gateway.dart';
import 'package:eduquest/features/assistant/domain/ai_chat_action.dart';
import 'package:eduquest/features/assistant/domain/ai_chat_message.dart';
import 'package:eduquest/features/assistant/domain/ai_composer_attachment.dart';
import 'package:eduquest/features/assistant/domain/ai_quiz_payload.dart';
import 'package:eduquest/features/assistant/presentation/assistant_seed_bus.dart';
import 'package:eduquest/features/assistant/presentation/widgets/ai_message_card.dart';
import 'package:eduquest/features/assistant/data/quiz_result_snapshot.dart';
import 'package:eduquest/features/learning/domain/exam_category.dart';
import 'package:eduquest/features/learning/presentation/pages/chapter_course_page.dart';
import 'package:eduquest/features/learning/presentation/pages/exam_list_page.dart';
import 'package:eduquest/features/assistant/presentation/widgets/ai_prompt_bar.dart';
import 'package:eduquest/features/assistant/presentation/widgets/assistant_artifact.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/sync/service_locator.dart';
import 'package:eduquest/shared/sync/offline_view_state.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/glass_container.dart';
import 'package:eduquest/shared/ui/widgets/math_markdown.dart';
import 'package:eduquest/shared/ui/widgets/ruach_bottom_sheet.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:flutter/material.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

enum _ImageSourceChoice { camera, gallery }

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({
    super.key,
    this.repository,
    this.analytics,
    this.offlineState,
    this.imagePicker,
  });
  final AiAssistantRepository? repository;
  final AppAnalytics? analytics;
  final OfflineViewState? offlineState;
  final ImagePickerGateway? imagePicker;
  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  static const _statusLabels = [
    'Je cherche dans tes cours…',
    'Je vérifie sous un autre angle…',
    'Je prépare une réponse claire…',
  ];

  late final AiAssistantRepository _repo;
  late final AppAnalytics _analytics;
  late final OfflineViewState _offline;
  late final ImagePickerGateway _picker;
  final _text = TextEditingController();
  final _scroll = ScrollController();
  final _suggestions = const ['Explique ce chapitre simplement', 'Donne-moi 3 points clés', 'Résume le PDF en 5 lignes'];
  final _messages = <AiChatMessage>[];
  String? _threadId;
  bool _loading = true, _sending = false;
  AiComposerAttachment? _attachment;
  Timer? _statusTimer;
  int _statusIndex = 0;
  // Libellé transitoire pendant qu'un outil de calcul tourne (« Je trace… »).
  String? _toolLabel;
  // Texte en cours de génération, mis à jour token par token sans reconstruire toute la liste :
  // seule la bulle qui écoute ce notifier se redessine (voir _liveBubble/ValueListenableBuilder).
  final _streamingText = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AiAssistantRepository();
    _analytics = widget.analytics ?? AppAnalytics();
    _offline = widget.offlineState ?? LocatorOfflineViewState(ServiceLocator().notifier);
    _picker = widget.imagePicker ?? DeviceImagePickerGateway();
    _offline.addListener(_onOffline);
    AssistantSeedBus.notifier.addListener(_onSeedChanged);
    _boot();
  }

  @override
  void dispose() {
    _offline.removeListener(_onOffline);
    AssistantSeedBus.notifier.removeListener(_onSeedChanged);
    _text.dispose();
    _scroll.dispose();
    _statusTimer?.cancel();
    _streamingText.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final data = await _repo.load();
    if (!mounted) return;
    _threadId = data.$1;
    _messages
      ..clear()
      ..addAll(data.$2);
    setState(() => _loading = false);
    _scrollToBottom();
    await _analytics.track('ai_screen_opened', category: 'learning');
    if (!_offline.isOffline) await _drainQueued();
    // Le bus retient sa dernière valeur : un seed émis juste avant que cet
    // onglet ne soit monté pour la première fois (LazyTabStack) doit être
    // consommé ici, pas seulement via le listener (qui ne réagit qu'aux
    // changements futurs).
    _onSeedChanged();
  }

  void _onSeedChanged() {
    final seed = AssistantSeedBus.notifier.value;
    if (seed == null || !mounted || _sending) return;
    AssistantSeedBus.clear();
    if (seed.image != null) setState(() => _attachment = seed.image);
    unawaited(_send(
      seed: seed.prompt,
      mode: seed.mode,
      subjectId: seed.subjectId,
      presentDirectly: seed.presentDirectly,
    ));
  }

  Future<void> _onOffline() async {
    if (!_offline.isOffline) await _drainQueued();
    if (mounted) setState(() {});
  }

  Future<void> _persist() => _repo.persist(_threadId, _messages);

  void _scrollToBottom({bool animate = true}) {
    void go() {
      if (!mounted || !_scroll.hasClients) return;
      final target = _scroll.position.maxScrollExtent;
      if ((_scroll.offset - target).abs() < 1) return;
      if (animate) {
        _scroll.animateTo(target, duration: RuachMotion.appear, curve: Curves.easeOut);
      } else {
        // Streaming token par token : jump direct, pas d'animations empilées.
        _scroll.jumpTo(target);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      go();
      // La bulle qu'on vient d'ajouter (et le squelette) ne sont parfois
      // mesurés qu'au frame suivant : `maxScrollExtent` était sous-évalué,
      // et on restait « au milieu ». Deuxième passe pour finir en bas.
      WidgetsBinding.instance.addPostFrameCallback((_) => go());
    });
  }

  void _startStatusCycle() {
    _statusIndex = 0;
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
      if (!mounted) return;
      setState(() => _statusIndex = (_statusIndex + 1) % _statusLabels.length);
    });
  }

  void _stopStatusCycle() {
    _statusTimer?.cancel();
    _statusTimer = null;
  }

  Future<void> _attachImage() async {
    final choice = await RuachBottomSheet.show<_ImageSourceChoice>(
      context,
      title: 'Joindre une image',
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: const Icon(Icons.photo_camera_outlined),
          title: const Text('Prendre une photo'),
          onTap: () => Navigator.pop(context, _ImageSourceChoice.camera),
        ),
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: const Text('Choisir dans la galerie'),
          onTap: () => Navigator.pop(context, _ImageSourceChoice.gallery),
        ),
      ]),
    );
    if (choice == null || !mounted) return;
    final attachment = choice == _ImageSourceChoice.camera
        ? await _picker.pickFromCamera()
        : await _picker.pickFromGallery();
    if (attachment == null || !mounted) return;
    setState(() => _attachment = attachment);
  }

  void _removeAttachment() => setState(() => _attachment = null);

  /// Referme le clavier et empêche le champ de reprendre le focus tout seul.
  /// `EditableText` peut re-demander le focus juste après un `onSubmitted` /
  /// un rebuild — d'où la passe post-frame en plus de l'appel synchrone.
  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  Future<void> _send({
    String? seed,
    String? mode,
    String? subjectId,
    bool presentDirectly = false,
  }) async {
    final prompt = (seed ?? _text.text).trim();
    final attachment = _attachment;
    if ((prompt.isEmpty && attachment == null) || _sending) return;
    _text.clear();
    _dismissKeyboard();
    setState(() => _attachment = null);
    await _analytics.track('ai_prompt_sent', category: 'learning', payload: {
      'length': prompt.length,
      'has_image': attachment != null,
    });
    if (_offline.isOffline) {
      // `presentDirectly` (notification IA) suppose une réponse immédiate ;
      // hors ligne, la mise en file n'a de sens que pour une vraie question
      // tapée par l'élève, jamais visible ici.
      if (!presentDirectly) {
        _messages.add(AiChatMessage(role: 'user', body: prompt, createdAt: DateTime.now(), status: 'queued'));
        setState(() {});
        _scrollToBottom();
        await _persist();
      }
      await _analytics.track('ai_offline_question_queued', category: 'technical');
      return;
    }
    setState(() {
      _sending = true;
      _streamingText.value = '';
      if (!presentDirectly) {
        _messages.add(AiChatMessage(
          role: 'user',
          body: prompt.isEmpty ? '(image jointe)' : prompt,
          createdAt: DateTime.now(),
          hasImage: attachment != null,
        ));
      }
    });
    _scrollToBottom();
    _startStatusCycle();
    try {
      final reply = await _repo.ask(
        prompt.isEmpty ? 'Analyse cette image.' : prompt,
        threadId: _threadId,
        image: attachment,
        mode: mode,
        subjectId: subjectId,
        onDelta: _onStreamDelta,
        onTool: _onToolStatus,
      );
      _threadId = reply.threadId;
      _messages.add(AiChatMessage(
        role: reply.message.role,
        body: reply.message.body,
        createdAt: reply.message.createdAt,
        status: reply.message.status,
        responseKind: reply.message.responseKind,
        quiz: reply.quiz,
        artifacts: reply.artifacts,
        action: reply.message.action,
      ));
      await _analytics.track('ai_response_received', category: 'learning');
      if (reply.cached) await _analytics.track('ai_cached_answer_used', category: 'technical');
    } catch (e) {
      _messages.add(AiChatMessage(
        role: 'assistant',
        body: 'Je n’ai pas assez d’informations pour répondre correctement à cette question.',
        createdAt: DateTime.now(),
        status: 'failed',
        responseKind: 'fallback',
      ));
      await _analytics.track('ai_response_failed', category: 'technical', payload: {'error': e.toString()});
    }
    _stopStatusCycle();
    _streamingText.value = null;
    if (mounted) setState(() { _sending = false; _toolLabel = null; });
    _dismissKeyboard();
    _scrollToBottom();
    await _persist();
  }

  void _onStreamDelta(String delta) {
    if (_statusTimer != null) _stopStatusCycle();
    if (_toolLabel != null && mounted) setState(() => _toolLabel = null);
    _streamingText.value = (_streamingText.value ?? '') + delta;
    _scrollToBottom(animate: false);
  }

  static const _toolLabels = {
    'plot_function': 'Je trace la courbe…',
    'evaluate': 'Je calcule…',
    'solve': 'Je résous l’équation…',
  };

  void _onToolStatus(String tool, String status) {
    if (!mounted) return;
    setState(() => _toolLabel = status == 'error'
        ? null
        : (_toolLabels[tool] ?? 'Je calcule…'));
  }

  // Catégorie renvoyée par l'assistant (déjà mappée côté Edge Function) ->
  // enum client. Toute valeur inconnue neutralise le bouton (retour null).
  static const _examCategories = {
    'national': ExamCategory.national,
    'epreuve': ExamCategory.epreuve,
    'mock': ExamCategory.mock,
  };

  Future<void> _openAction(AiChatAction action) async {
    if (action.isOpenExamList) {
      final category = _examCategories[action.category];
      final subjectId = action.subjectId;
      if (category == null || subjectId == null || !mounted) return;
      await _analytics.track('ai_exam_action_opened', category: 'learning', payload: {
        'category': action.category ?? '',
      });
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ExamListPage(
          subjectId: subjectId,
          subjectLabel: action.subjectLabel ?? 'Épreuves',
          category: category,
        ),
      ));
      return;
    }
    if (action.isOpenChapter) {
      final chapterId = action.chapterId;
      if (chapterId == null || !mounted) return;
      await _analytics.track('ai_chapter_action_opened', category: 'learning');
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChapterCoursePage(
          chapterId: chapterId,
          chapterTitle: action.chapterTitle ?? 'Chapitre',
        ),
      ));
    }
  }

  Future<void> _drainQueued() async {
    if (_sending) return;
    final queued = _messages.where((m) => m.role == 'user' && m.status == 'queued').toList();
    if (queued.isEmpty) return;
    for (final m in queued) {
      final i = _messages.indexOf(m);
      if (i < 0) continue;
      _messages[i] = AiChatMessage(role: m.role, body: m.body, createdAt: m.createdAt);
      if (mounted) setState(() => _sending = true);
      try {
        final reply = await _repo.ask(m.body, threadId: _threadId, onTool: _onToolStatus);
        _threadId = reply.threadId;
        _messages.add(AiChatMessage(
          role: reply.message.role,
          body: reply.message.body,
          createdAt: reply.message.createdAt,
          responseKind: reply.message.responseKind,
          quiz: reply.quiz,
          artifacts: reply.artifacts,
          action: reply.message.action,
        ));
      } catch (_) {
        _messages[i] = m;
        break;
      } finally {
        if (mounted) setState(() { _sending = false; _toolLabel = null; });
      }
    }
    _scrollToBottom();
    await _persist();
  }

  Future<void> _onQuizCompleted(QuizResult result, QuizDefinition definition, AiQuizPayload? payload) async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _streamingText.value = '';
    });
    _scrollToBottom();
    _startStatusCycle();
    try {
      final snapshot = buildQuizResultSnapshot(result, definition);
      final reply = await _repo.ask(
        'Quiz terminé.',
        threadId: _threadId,
        quizResult: {
          'scorePercent': result.scorePercent,
          'correctCount': result.correctCount,
          'wrongCount': result.wrongCount,
          'totalQuestions': result.totalQuestions,
          'source': payload?.source,
          'quizId': payload?.quizId,
          'subjectId': payload?.subjectId,
          'chapterId': payload?.chapterId,
          ...snapshot,
        },
        onDelta: _onStreamDelta,
        onTool: _onToolStatus,
      );
      _threadId = reply.threadId;
      _messages.add(AiChatMessage(
        role: reply.message.role,
        body: reply.message.body,
        createdAt: reply.message.createdAt,
        responseKind: reply.message.responseKind,
        artifacts: reply.artifacts,
        action: reply.message.action,
      ));
      await _analytics.track('ai_response_received', category: 'learning');
    } catch (_) {
      // best-effort : le score est déjà affiché dans la bulle du quiz, un échec ici n'est pas bloquant.
    }
    _stopStatusCycle();
    _streamingText.value = null;
    if (mounted) setState(() { _sending = false; _toolLabel = null; });
    _scrollToBottom();
    await _persist();
  }

  Widget _liveBubble(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.symmetric(horizontal: RuachSpace.s3, vertical: RuachSpace.s2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: ValueListenableBuilder<String?>(
        valueListenable: _streamingText,
        builder: (context, text, __) {
          if (text == null || text.isEmpty) {
            return Row(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: RuachSpace.s2),
              Text(_toolLabel ?? _statusLabels[_statusIndex],
                  style: Theme.of(context).textTheme.bodySmall),
            ]);
          }
          return MathMarkdown(data: text);
        },
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(children: [
    // Cet onglet n'a pas d'AppBar reel (contrairement aux autres onglets du
    // Scaffold parent) -- SafeArea evite que l'en-tete se dessine sous la
    // barre de statut/notifications.
    SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(RuachSpace.s4, RuachSpace.s4, RuachSpace.s4, RuachSpace.s2),
        child: GlassContainer(
          child: Row(children: [
            const Expanded(child: Text('Assistant RuachEdu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
            if (_offline.isOffline) const Chip(label: Text('Hors ligne')),
          ]),
        ),
      ),
    ),
    Expanded(
      child: _loading
          ? const Center(child: RuachLoader(label: 'Chargement assistant'))
          : _messages.isEmpty
              ? ListView(padding: const EdgeInsets.all(RuachSpace.s4), children: [
                  const SizedBox(height: RuachSpace.s6),
                  for (final s in _suggestions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: RuachSpace.s2),
                      child: OutlinedButton(onPressed: () => _send(seed: s), child: Text(s)),
                    ),
                ])
              : ListView.separated(
                  controller: _scroll,
                  padding: const EdgeInsets.all(RuachSpace.s4),
                  itemBuilder: (_, i) {
                    if (i >= _messages.length) {
                      final tool = _toolLabel;
                      if (tool == null) return _liveBubble(context);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _liveBubble(context),
                          ),
                          const SizedBox(height: RuachSpace.s3),
                          AssistantArtifactSkeleton(label: tool),
                        ],
                      );
                    }
                    final m = _messages[i];
                    return AiMessageCard(
                      message: m,
                      onQuizCompleted: (result, definition) => _onQuizCompleted(result, definition, m.quiz),
                      onOpenAction: _openAction,
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
                  itemCount: _messages.length + (_sending ? 1 : 0),
                ),
    ),
    AiPromptBar(
      controller: _text,
      sending: _sending,
      onSend: _send,
      onAttach: _attachImage,
      onRemoveAttachment: _removeAttachment,
      attachment: _attachment,
    ),
  ]);
}
