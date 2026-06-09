import 'dart:async';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/domain/learning_chapter.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/learning/presentation/pages/chapter_navigation.dart';
import 'package:eduquest/features/learning/presentation/pages/widgets/chapter_list_body.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/shared/network/network_probe.dart';
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
class _ChapterListPageState extends State<ChapterListPage> with AutomaticKeepAliveClientMixin {
  final _repo = LearningCatalogRepository();
  final _notif = NotificationService();
  List<LearningChapter> _items = const [];
  bool _loading = true;
  String? _openingId;
  bool _offlineWarned = false;
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
    if (mounted && !background && _items.isEmpty) setState(() => _loading = true);
    final hadCache = await _repo.hasChaptersCache(widget.subjectId);
    final data = await _repo.chaptersBySubject(widget.subjectId);
    if (!mounted) return;
    setState(() { _items = data; _loading = false; });
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
    if (await NetworkProbe.hasConnection() || !mounted) return;
    _offlineWarned = true;
    unawaited(_notif.sendOfflineContentWarning(label));
    await showOfflineBootstrapAlert(context, contentLabel: label);
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
    return ChapterListBody(
      subjectLabel: widget.subjectLabel,
      items: _items,
      openingId: _openingId,
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
