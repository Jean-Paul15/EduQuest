import 'dart:async';
import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/learning/data/chapter_content_repository.dart';
import 'package:eduquest/features/learning/domain/learning_quiz.dart';
import 'package:eduquest/features/learning/presentation/widgets/quiz_list_item.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/offline_bootstrap_alert.dart';
import 'package:eduquest/shared/ui/ruach_animations.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ChapterQuizListPage extends StatefulWidget {
  const ChapterQuizListPage({
    super.key,
    required this.chapterId,
    this.initialItems,
  });
  final String chapterId;
  final List<LearningQuiz>? initialItems;
  @override
  State<ChapterQuizListPage> createState() => _ChapterQuizListPageState();
}

class _ChapterQuizListPageState extends State<ChapterQuizListPage>
    with AutomaticKeepAliveClientMixin {
  final _repo = ChapterContentRepository();
  final _notif = NotificationService();
  List<LearningQuiz> _items = const [];
  bool _loading = true;
  bool _offlineWarned = false;

  @override
  void initState() {
    super.initState();
    final seededFromNav = widget.initialItems;
    if (seededFromNav != null && seededFromNav.isNotEmpty) {
      _items = seededFromNav;
      _loading = false;
      _load(background: true);
      return;
    }
    final seeded = _repo.peekQuizzes(widget.chapterId);
    if (seeded != null && seeded.isNotEmpty) {
      _items = seeded;
      _loading = false;
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
    if (data.isEmpty) {
      await _warnIfOfflineBootstrap(hadCache: hadCache);
    }
  }

  Future<void> _warnIfOfflineBootstrap({required bool hadCache}) async {
    if (_offlineWarned || hadCache) return;
    final online = await NetworkProbe.hasConnection();
    if (online || !mounted) return;
    _offlineWarned = true;
    unawaited(_notif.sendOfflineContentWarning('les QCM'));
    await showOfflineBootstrapAlert(context, contentLabel: 'les QCM');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) {
      return const EmptyState(
        title: 'Aucun QCM',
        subtitle: 'Pas de QCM pour ce chapitre.',
        icon: PhosphorIconsRegular.puzzlePiece,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(RuachSpace.s4),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
      itemBuilder: (_, i) {
        final e = _items[i];
        return staggerItem(
          index: i,
          child: QuizListItem(
            key: ValueKey(e.id),
            quiz: e,
            onTap: () => context.pushNamed(AppRoutes.qcmAttempt, pathParameters: {'quizId': e.id}, queryParameters: {'title': e.title}),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
