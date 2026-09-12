import 'dart:async';
import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/learning/data/chapter_content_repository.dart';
import 'package:eduquest/features/learning/data/learning_content_repository.dart';
import 'package:eduquest/features/learning/data/local_quiz_result_repository.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';
import 'package:eduquest/features/learning/presentation/widgets/quiz_list_item.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/offline_content_guard.dart';
import 'package:eduquest/shared/ui/ruach_animations.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';

class ChapterQuizListPage extends StatefulWidget {
  const ChapterQuizListPage({
    super.key,
    required this.chapterId,
    this.initialItems,
  });
  final String chapterId;
  final List<QuizSummary>? initialItems;
  @override
  State<ChapterQuizListPage> createState() => _ChapterQuizListPageState();
}

class _ChapterQuizListPageState extends State<ChapterQuizListPage>
    with AutomaticKeepAliveClientMixin, RealtimeRefreshable<ChapterQuizListPage> {
  @override
  List<String> get realtimeNamespaces => const ['chapter'];

  @override
  Future<void> reloadFromRealtime() => _load(background: true);

  final _repo = ChapterContentRepository();
  final _contentRepo = LearningContentRepository();
  final _local = LocalJsonCache();
  final _resultsRepo = LocalQuizResultRepository();
  List<QuizSummary> _items = const [];
  Set<String> _offlineIds = const {};
  Set<String> _resumeIds = const {};
  Map<String, ({int scorePercent, bool passed})> _lastResults = const {};
  final Set<String> _warmingIds = {};
  bool _loading = true;
  bool _offlineWarned = false;

  @override
  void initState() {
    super.initState();
    final seededFromNav = widget.initialItems;
    if (seededFromNav != null && seededFromNav.isNotEmpty) {
      _items = seededFromNav;
      _loading = false;
      unawaited(_loadItemStates());
      _load(background: true);
      return;
    }
    final seeded = _repo.peekQuizzes(widget.chapterId);
    if (seeded != null && seeded.isNotEmpty) {
      _items = seeded;
      _loading = false;
      unawaited(_loadItemStates());
      _load(background: true);
      return;
    }
    _load();
  }

  Future<void> _load({bool background = false}) async {
    if (mounted && !background && _items.isEmpty) {
      setState(() => _loading = true);
    }
    final hadCache = await _repo.hasQuizCache(widget.chapterId);
    final data = await _repo.quizzes(widget.chapterId);
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
    unawaited(_loadItemStates());
    if (data.isEmpty && !_offlineWarned && !hadCache) {
      _offlineWarned = await guardOfflineContent(
        context: context,
        contentLabel: 'les QCM',
      );
    }
  }

  Future<void> _loadItemStates() async {
    final checks = await Future.wait(
      _items.map(
        (quiz) async => (
          id: quiz.id,
          resume: await _local.hasKey('session:quiz:${quiz.id}'),
          offline: await _contentRepo.hasQuizBundleCache(quiz.id),
        ),
      ),
    );
    final resumeIds = checks
        .where((entry) => entry.resume)
        .map((entry) => entry.id)
        .toSet();
    final offlineIds = checks
        .where((entry) => entry.offline)
        .map((entry) => entry.id)
        .toSet();
    final history = await _resultsRepo.loadHistory();
    final lastResults = <String, ({int scorePercent, bool passed})>{};
    for (final row in history) {
      final quizId = '${row['quiz_id']}';
      if (lastResults.containsKey(quizId)) continue;
      lastResults[quizId] = (
        scorePercent: ((row['score_percent'] as num?) ?? 0).round(),
        passed: row['passed'] == true,
      );
    }
    if (!mounted) return;
    setState(() {
      _resumeIds = resumeIds;
      _offlineIds = offlineIds;
      _lastResults = lastResults;
    });
    _warmPriorityBundles(resumeIds, offlineIds);
  }

  void _warmPriorityBundles(Set<String> resumeIds, Set<String> offlineIds) {
    final queue = <String>[
      ..._items
          .where(
            (quiz) =>
                resumeIds.contains(quiz.id) && !offlineIds.contains(quiz.id),
          )
          .map((quiz) => quiz.id),
      if (_items.isNotEmpty && !offlineIds.contains(_items.first.id))
        _items.first.id,
    ];
    for (final quizId in queue.toSet()) {
      if (!_warmingIds.add(quizId)) continue;
      unawaited(
        _contentRepo.warmQuizBundle(quizId).whenComplete(() async {
          _warmingIds.remove(quizId);
          if (!mounted) return;
          if (await _contentRepo.hasQuizBundleCache(quizId)) {
            setState(() => _offlineIds = {..._offlineIds, quizId});
          }
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return _buildLoading();
    if (_items.isEmpty) {
      return EmptyState(
        title: 'Aucun QCM',
        subtitle: 'Pas de QCM pour ce chapitre.',
        icon: PhosphorIconsRegular.puzzlePiece,
        actionLabel: 'Actualiser',
        onAction: _load,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(RuachSpace.s4),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
        itemBuilder: (_, i) {
          final e = _items[i];
          return staggerItem(
            key: ValueKey(e.id),
            index: i,
            child: QuizListItem(
              quiz: e,
              hasSavedProgress: _resumeIds.contains(e.id),
              isOfflineReady: _offlineIds.contains(e.id),
              lastResult: _lastResults[e.id],
              onTap: () async {
                await context.pushNamed(
                  AppRoutes.quizIntro,
                  pathParameters: {'quizId': e.id},
                  queryParameters: {
                    'title': e.title,
                    if (e.questionCount != null)
                      'questionCount': '${e.questionCount}',
                    if (e.timePerQuestionSeconds != null)
                      'timePerQuestionSeconds': '${e.timePerQuestionSeconds}',
                    'hasSavedProgress': '${_resumeIds.contains(e.id)}',
                  },
                );
                if (!mounted) return;
                unawaited(_loadItemStates());
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() => ListView.separated(
    padding: const EdgeInsets.all(RuachSpace.s4),
    itemCount: 4,
    separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
    itemBuilder: (_, __) => RuachSkeleton(
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RuachRadius.lg),
        ),
      ),
    ),
  );

  @override
  bool get wantKeepAlive => true;
}
