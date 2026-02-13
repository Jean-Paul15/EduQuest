import 'dart:async';
import 'package:eduquest/features/learning/data/exam_repository.dart';
import 'package:eduquest/features/learning/domain/exam_category.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/data/learning_warmup_service.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/learning/domain/learning_subject.dart';
import 'package:eduquest/features/learning/presentation/pages/chapter_list_page.dart';
import 'package:eduquest/features/learning/presentation/pages/exam_list_page.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/offline_bootstrap_alert.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class SubjectSectionPage extends StatefulWidget {
  const SubjectSectionPage({super.key, required this.section});
  final LearningSection section;
  @override
  State<SubjectSectionPage> createState() => _SubjectSectionPageState();
}

class _SubjectSectionPageState extends State<SubjectSectionPage>
    with AutomaticKeepAliveClientMixin {
  final _catalog = LearningCatalogRepository();
  final _exams = ExamRepository();
  final _warmup = LearningWarmupService();
  final _notif = NotificationService();
  List<LearningSubject> _items = const [];
  bool _loading = true;
  String? _openingId;
  bool _offlineWarned = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted && _items.isEmpty) setState(() => _loading = true);
    final s = widget.section;
    final hadCache = switch (s) {
      LearningSection.exams => await _exams.hasSubjectsCache(
        ExamCategory.national,
      ),
      LearningSection.epreuves => await _exams.hasSubjectsCache(
        ExamCategory.epreuve,
      ),
      LearningSection.mockExams => await _exams.hasSubjectsCache(
        ExamCategory.mock,
      ),
      _ => await _catalog.hasSubjectsCacheForCourses(),
    };
    final data = switch (s) {
      LearningSection.exams => await _exams.subjects(ExamCategory.national),
      LearningSection.epreuves => await _exams.subjects(ExamCategory.epreuve),
      LearningSection.mockExams => await _exams.subjects(ExamCategory.mock),
      _ => await _catalog.subjectsForCourses(),
    };
    if (mounted) {
      setState(() {
        _items = data;
        _loading = false;
      });
    }
    if (data.isEmpty) {
      await _warnIfOfflineBootstrap(
        hadCache: hadCache,
        label: 'les matières de ${widget.section.label}',
      );
    }
    for (final sub in data.take(8)) {
      unawaited(_warmup.warmBeforeOpenSubject(s, sub.id));
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

  ExamCategory? get _examCat => switch (widget.section) {
    LearningSection.exams => ExamCategory.national,
    LearningSection.epreuves => ExamCategory.epreuve,
    LearningSection.mockExams => ExamCategory.mock,
    _ => null,
  };

  Future<void> _open(LearningSubject s) async {
    if (mounted) setState(() => _openingId = s.id);
    try {
      if (!mounted) return;
      final cat = _examCat;
      if (cat != null) {
        final papers = await _exams
            .listBySubject(subjectId: s.id, category: cat)
            .timeout(const Duration(milliseconds: 1800));
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExamListPage(
              subjectId: s.id,
              subjectLabel: s.label,
              category: cat,
              initialEntries: papers,
            ),
          ),
        );
      } else {
        final chapters = await _catalog
            .chaptersBySubject(s.id)
            .timeout(const Duration(milliseconds: 1800));
        if (!mounted) return;
        unawaited(_warmup.warmBeforeOpenSubject(widget.section, s.id));
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChapterListPage(
              subjectId: s.id,
              subjectLabel: s.label,
              section: widget.section,
              initialChapters: chapters,
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      final cat = _examCat;
      if (cat != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExamListPage(
              subjectId: s.id,
              subjectLabel: s.label,
              category: cat,
            ),
          ),
        );
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChapterListPage(
              subjectId: s.id,
              subjectLabel: s.label,
              section: widget.section,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) {
      return EmptyState(
        title: 'Aucune matiere',
        subtitle: 'Aucune matiere disponible dans ${widget.section.label}.',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
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
                e.label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
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
