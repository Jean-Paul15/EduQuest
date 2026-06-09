import 'dart:async';
import 'package:eduquest/features/learning/data/exam_repository.dart';
import 'package:eduquest/features/learning/domain/exam_category.dart';
import 'package:eduquest/features/learning/domain/exam_entry.dart';
import 'package:eduquest/features/learning/presentation/pages/exam_detail_page.dart';
import 'package:eduquest/features/learning/presentation/pages/widgets/exam_list_body.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:eduquest/shared/ui/offline_bootstrap_alert.dart';
import 'package:flutter/material.dart';

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

class _ExamListPageState extends State<ExamListPage> with AutomaticKeepAliveClientMixin {
  final _repo = ExamRepository();
  final _notif = NotificationService();
  List<ExamEntry> _items = const [];
  bool _loading = true;
  bool _offlineWarned = false;

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
    final seeded = _repo.peekPapers(subjectId: widget.subjectId, category: widget.category);
    if (seeded != null && seeded.isNotEmpty) {
      _items = seeded;
      _loading = false;
      _load(background: true);
      return;
    }
    _load();
  }

  Future<void> _load({bool background = false}) async {
    if (mounted && !background && _items.isEmpty) setState(() => _loading = true);
    final hadCache = await _repo.hasPapersCache(subjectId: widget.subjectId, category: widget.category);
    final data = await _repo.listBySubject(subjectId: widget.subjectId, category: widget.category);
    if (!mounted) return;
    setState(() { _items = data; _loading = false; });
    if (data.isEmpty) await _warnIfOfflineBootstrap(hadCache: hadCache, label: 'les documents de ${widget.subjectLabel}');
  }

  Future<void> _warnIfOfflineBootstrap({required bool hadCache, required String label}) async {
    if (_offlineWarned || hadCache) return;
    final online = await NetworkProbe.hasConnection();
    if (online || !mounted) return;
    _offlineWarned = true;
    unawaited(_notif.sendOfflineContentWarning(label));
    await showOfflineBootstrapAlert(context, contentLabel: label);
  }

  void _onEntryTap(ExamEntry e) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ExamDetailPage(title: e.title, paperUrl: e.paperUrl, correctionUrl: e.correctionUrl),
    ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ExamListBody(loading: _loading, items: _items, subjectLabel: widget.subjectLabel, onEntryTap: _onEntryTap);
  }

  @override
  bool get wantKeepAlive => true;
}
