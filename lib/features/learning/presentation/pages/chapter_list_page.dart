import 'dart:async';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/data/chapter_content_repository.dart';
import 'package:eduquest/features/learning/domain/chapter_resource.dart';
import 'package:eduquest/features/learning/domain/learning_chapter.dart';
import 'package:eduquest/features/learning/domain/learning_quiz.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/learning/presentation/pages/chapter_course_page.dart';
import 'package:eduquest/features/learning/presentation/pages/chapter_media_page.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/offline_bootstrap_alert.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class ChapterListPage extends StatefulWidget {
  const ChapterListPage({
    super.key,
    required this.subjectId,
    required this.subjectLabel,
    required this.section,
    this.initialChapters,
  });
  final String subjectId;
  final String subjectLabel;
  final LearningSection section;
  final List<LearningChapter>? initialChapters;
  @override
  State<ChapterListPage> createState() => _ChapterListPageState();
}

class _ChapterListPageState extends State<ChapterListPage>
    with AutomaticKeepAliveClientMixin {
  final _repo = LearningCatalogRepository();
  final _chapter = ChapterContentRepository();
  final _notif = NotificationService();
  List<LearningChapter> _items = const [];
  bool _loading = true;
  String? _openingId;
  bool _offlineWarned = false;

  @override
  void initState() {
    super.initState();
    final seededFromNav = widget.initialChapters;
    if (seededFromNav != null && seededFromNav.isNotEmpty) {
      _items = seededFromNav;
      _loading = false;
      _load(background: true);
      return;
    }
    final seeded = _repo.peekChaptersForSubject(widget.subjectId);
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
    final hadCache = await _repo.hasChaptersCache(widget.subjectId);
    final data = await _repo.chaptersBySubject(widget.subjectId);
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
    if (data.isEmpty) {
      await _warnIfOfflineBootstrap(
        hadCache: hadCache,
        label: 'les chapitres de ${widget.subjectLabel}',
      );
    }
  }

  Future<void> _warnIfOfflineBootstrap({
    required bool hadCache,
    required String label,
  }) async {
    if (_offlineWarned || hadCache) return;
    final online = await NetworkProbe.hasConnection();
    if (online || !mounted) return;
    _offlineWarned = true;
    unawaited(_notif.sendOfflineContentWarning(label));
    await showOfflineBootstrapAlert(context, contentLabel: label);
  }

  Future<void> _open(LearningChapter c) async {
    if (mounted) setState(() => _openingId = c.id);
    try {
      if (widget.section == LearningSection.courses) {
        final loaded = await Future.wait([
          _chapter.resources(chapterId: c.id, type: 'pdf'),
          _chapter.resources(chapterId: c.id, type: 'exercise_set'),
          _chapter.resources(chapterId: c.id, type: 'summary'),
          _chapter.quizzes(c.id),
        ]).timeout(const Duration(milliseconds: 2200));
        final summaries = loaded[0] as List<ChapterResource>;
        final exercises = loaded[1] as List<ChapterResource>;
        final corrections = loaded[2] as List<ChapterResource>;
        final quizzes = loaded[3] as List<LearningQuiz>;
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChapterCoursePage(
              chapterId: c.id,
              chapterTitle: c.title,
              initialSummaries: summaries,
              initialExercises: exercises,
              initialCorrections: corrections,
              initialQuizzes: quizzes,
            ),
          ),
        );
        return;
      }
      final type = widget.section == LearningSection.youtube
          ? 'youtube'
          : 'video';
      final items = await _chapter
          .resources(chapterId: c.id, type: type)
          .timeout(const Duration(milliseconds: 1800));
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChapterMediaPage(
            chapterId: c.id,
            chapterTitle: c.title,
            type: type,
            initialItems: items,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      final type = widget.section == LearningSection.youtube
          ? 'youtube'
          : 'video';
      final isCourse = widget.section == LearningSection.courses;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => isCourse
              ? ChapterCoursePage(chapterId: c.id, chapterTitle: c.title)
              : ChapterMediaPage(
                  chapterId: c.id,
                  chapterTitle: c.title,
                  type: type,
                ),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_items.isEmpty) {
      return const EmptyState(
        title: 'Aucun chapitre',
        subtitle: 'Aucun chapitre disponible.',
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.subjectLabel)),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpace.l),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpace.s),
        itemBuilder: (_, i) {
          final e = _items[i];
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: ListTile(
              title: Text(
                e.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Chapitre ${e.position + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              trailing: _openingId == e.id
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textTertiary,
                    ),
              onTap: () => _open(e),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
