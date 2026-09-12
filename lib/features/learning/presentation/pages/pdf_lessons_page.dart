import 'dart:async';
import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/learning/data/pdf_lesson_repository.dart';
import 'package:eduquest/features/learning/domain/pdf_lesson.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/ruach_animations.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eduquest/features/learning/presentation/widgets/pdf_lesson_tile.dart';

class PdfLessonsPage extends StatefulWidget {
  const PdfLessonsPage({super.key});
  @override
  State<PdfLessonsPage> createState() => _PdfLessonsPageState();
}

class _PdfLessonsPageState extends State<PdfLessonsPage>
    with RealtimeRefreshable<PdfLessonsPage> {
  final _repo = PdfLessonRepository();
  final _analytics = AppAnalytics();
  List<PdfLesson> _lessons = const [];
  final Map<String, bool> _offline = {};
  bool _loading = true;

  @override
  List<String> get realtimeNamespaces => const ['chapter'];

  @override
  Future<void> reloadFromRealtime() => _load();

  @override
  void initState() {
    super.initState();
    unawaited(
      _analytics.track(
        'pdf_catalog_opened',
        category: 'resource',
        targetType: 'pdf',
      ),
    );
    _load();
  }

  Future<void> _load() async {
    if (mounted && _lessons.isEmpty) setState(() => _loading = true);
    final lessons = await _repo.listPublished();
    if (!mounted) return;
    final offlineChecks = await Future.wait(
      lessons.map(
        (l) async => MapEntry(l.id, await _repo.isAvailableOffline(l)),
      ),
    );
    if (!mounted) return;
    setState(() {
      _lessons = lessons;
      _loading = false;
      for (final entry in offlineChecks) {
        _offline[entry.key] = entry.value;
      }
    });
    unawaited(_silentRefresh(lessons));
  }

  Future<void> _silentRefresh(List<PdfLesson> lessons) async {
    await _repo.warmAndRefresh(lessons);
    final offlineChecks = await Future.wait(
      lessons.map(
        (l) async => MapEntry(l.id, await _repo.isAvailableOffline(l)),
      ),
    );
    if (mounted) {
      setState(() {
        for (final entry in offlineChecks) {
          _offline[entry.key] = entry.value;
        }
      });
    }
  }


  Future<void> _open(PdfLesson l) async {
    unawaited(
      _analytics.track(
        'pdf_viewer_opened',
        category: 'resource',
        targetType: 'pdf',
        targetId: l.id,
        payload: {'title': l.title},
      ),
    );
    await context.pushNamed(
      AppRoutes.pdfViewer,
      queryParameters: {
        'title': l.title,
        'url': l.url,
        'emptyLabel': 'PDF non disponible.',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading(context);
    if (_lessons.isEmpty) {
      return const EmptyState(
        title: 'Aucun PDF',
        subtitle: 'Aucun document PDF publié pour le moment.',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(RuachSpace.s4),
        itemCount: _lessons.length,
        separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
        itemBuilder: (_, i) {
          final l = _lessons[i];
          return staggerItem(
            key: ValueKey(l.id),
            index: i,
            child: PdfLessonTile(
              lesson: l,
              isOffline: _offline[l.id] == true,
              onTap: () => _open(l),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(RuachSpace.s4),
    itemCount: 4,
    separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
    itemBuilder: (_, __) => RuachSkeleton(
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RuachRadius.lg),
        ),
      ),
    ),
  );
}
