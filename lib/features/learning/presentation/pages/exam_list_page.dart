import 'dart:async';
import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/learning/data/exam_repository.dart';
import 'package:eduquest/features/learning/data/learning_scope_repository.dart';
import 'package:eduquest/features/learning/domain/exam_category.dart';
import 'package:eduquest/features/learning/domain/exam_entry.dart';
import 'package:eduquest/features/learning/presentation/pages/widgets/exam_list_body.dart';
import 'package:eduquest/shared/ui/offline_content_guard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';

class ExamListPage extends StatefulWidget {
  const ExamListPage({
    super.key,
    required this.subjectId,
    required this.subjectLabel,
    required this.category,
    this.initialEntries,
  });
  final String subjectId;
  final String subjectLabel;
  final ExamCategory category;
  final List<ExamEntry>? initialEntries;
  @override
  State<ExamListPage> createState() => _ExamListPageState();
}

class _ExamListPageState extends State<ExamListPage>
    with AutomaticKeepAliveClientMixin, RealtimeRefreshable<ExamListPage> {
  @override
  List<String> get realtimeNamespaces => const ['exam'];

  @override
  Future<void> reloadFromRealtime() => _load(background: true);

  final _repo = ExamRepository();
  List<ExamEntry> _items = const [];
  bool _loading = true;
  bool _offlineWarned = false;
  int _loadEpoch = 0;
  bool _seriesBlocked = false;

  @override
  void initState() {
    super.initState();
    final seededFromNav = widget.initialEntries;
    if (seededFromNav != null && seededFromNav.isNotEmpty) {
      _items = seededFromNav;
      _loading = false;
      _load(background: true);
      return;
    }
    final seeded = _repo.peekPapers(
      subjectId: widget.subjectId,
      category: widget.category,
    );
    if (seeded != null && seeded.isNotEmpty) {
      _items = seeded;
      _loading = false;
      _load(background: true);
      return;
    }
    _load();
  }

  Future<void> _load({bool background = false}) async {
    final request = ++_loadEpoch;
    final scope = await LearningScopeRepository().current();
    if (mounted && (!background || _items.isEmpty)) {
      setState(() => _loading = true);
    }
    final hadCache = await _repo.hasPapersCache(
      subjectId: widget.subjectId,
      category: widget.category,
    );
    final data = await _repo.listBySubject(
      subjectId: widget.subjectId,
      category: widget.category,
      forceRefresh: !background,
    );
    if (!mounted || request != _loadEpoch) return;
    setState(() {
      _items = data;
      _loading = false;
      _seriesBlocked = (scope?.seriesId?.isEmpty ?? true) || scope?.seriesId == null;
    });
    if (data.isEmpty) {
      await _warnIfOfflineBootstrap(
        hadCache: hadCache,
        label: 'les documents de ${widget.subjectLabel}',
      );
    }
  }

  Future<void> _warnIfOfflineBootstrap({
    required bool hadCache,
    required String label,
  }) async {
    if (_offlineWarned || hadCache || !mounted) return;
    _offlineWarned = await guardOfflineContent(
      context: context,
      contentLabel: label,
    );
  }

  void _onEntryTap(ExamEntry e) {
    context.pushNamed(
      AppRoutes.examDetail,
      queryParameters: {
        'title': e.title,
        'paperUrl': e.paperUrl,
        if (e.correctionUrl != null) 'correctionUrl': e.correctionUrl!,
        'subjectId': widget.subjectId,
        'subjectLabel': widget.subjectLabel,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ExamListBody(
      loading: _loading && _items.isEmpty,
      refreshing: _loading && _items.isNotEmpty,
      items: _items,
      subjectLabel: widget.subjectLabel,
      emptyTitle: _seriesBlocked ? 'Série requise' : null,
      emptySubtitle: _seriesBlocked
          ? 'Cette classe n’a pas encore de série active ciblable pour ces documents.'
          : null,
      onEntryTap: _onEntryTap,
      onRefresh: () => _load(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
