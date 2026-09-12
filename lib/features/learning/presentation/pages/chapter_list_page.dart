import 'dart:async';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/data/learning_scope_repository.dart';
import 'package:eduquest/features/learning/domain/learning_chapter.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/learning/presentation/pages/chapter_navigation.dart';
import 'package:eduquest/features/learning/presentation/pages/widgets/chapter_list_body.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:eduquest/shared/ui/offline_bootstrap_alert.dart';
import 'package:flutter/material.dart';
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';

typedef ChapterListLoader =
    Future<({List<LearningChapter> items, bool seriesBlocked})> Function();
class ChapterListPage extends StatefulWidget {
  const ChapterListPage({
    super.key,
    required this.subjectId,
    required this.subjectLabel,
    required this.section,
    this.initialChapters,
    this.loader,
  });
  final String subjectId;
  final String subjectLabel;
  final LearningSection section;
  final List<LearningChapter>? initialChapters;
  final ChapterListLoader? loader;
  @override
  State<ChapterListPage> createState() => _ChapterListPageState();
}
class _ChapterListPageState extends State<ChapterListPage> with AutomaticKeepAliveClientMixin, RealtimeRefreshable<ChapterListPage> {
  @override
  List<String> get realtimeNamespaces => const ['learn'];

  @override
  Future<void> reloadFromRealtime() => _load(background: true);

  final _repo = LearningCatalogRepository();
  final _notif = NotificationService();
  List<LearningChapter> _items = const [];
  bool _loading = true;
  String? _openingId;
  bool _offlineWarned = false;
  bool _seriesBlocked = false;
  bool _trySeed(List<LearningChapter>? p) {
    if (p == null || p.isEmpty) return false;
    _items = p;
    _loading = false;
    _load(background: true);
    return true;
  }
  @override
  void initState() {
    super.initState();
    if (_trySeed(widget.initialChapters)) return;
    if (_trySeed(_repo.peekChaptersForSubject(widget.subjectId))) return;
    _load();
  }
  Future<void> _load({bool background = false}) async {
    if (widget.loader != null) {
      final state = await widget.loader!();
      if (!mounted) return;
      setState(() {
        _items = state.items;
        _loading = false;
        _seriesBlocked = state.seriesBlocked;
      });
      return;
    }
    final scope = await LearningScopeRepository().current();
    if (mounted && !background && _items.isEmpty) setState(() => _loading = true);
    final results = await Future.wait<dynamic>([
      _repo.hasChaptersCache(widget.subjectId),
      _repo.chaptersBySubject(widget.subjectId),
    ]);
    final hadCache = results[0] as bool;
    final data = results[1] as List<LearningChapter>;
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
      _seriesBlocked = (scope?.seriesId?.isEmpty ?? true) || scope?.seriesId == null;
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
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChapterListBody(
      subjectLabel: widget.subjectLabel,
      loading: _loading,
      items: _items,
      openingId: _openingId,
      emptyTitle: _seriesBlocked ? 'Série requise' : null,
      emptySubtitle: _seriesBlocked
          ? 'Le contenu de ${widget.subjectLabel} sera visible dès qu’une série active sera liée à ta classe.'
          : null,
      onRefresh: _load,
      onChapterTap: (c) => ChapterNavigator.open(
        context: context,
        chapter: c,
        section: widget.section,
        isMounted: () => mounted,
        onOpeningIdChanged: (v) {
          if (mounted) setState(() => _openingId = v);
        },
      ),
    );
  }
  @override
  bool get wantKeepAlive => true;
}
