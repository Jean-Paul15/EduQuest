import 'dart:async';
import 'package:eduquest/features/learning/data/exam_repository.dart';
import 'package:eduquest/features/learning/domain/exam_category.dart';
import 'package:eduquest/features/learning/domain/exam_entry.dart';
import 'package:eduquest/features/learning/presentation/pages/exam_detail_page.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/offline_bootstrap_alert.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
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

class _ExamListPageState extends State<ExamListPage>
    with AutomaticKeepAliveClientMixin {
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
    if (mounted && !background && _items.isEmpty) {
      setState(() => _loading = true);
    }
    final hadCache = await _repo.hasPapersCache(
      subjectId: widget.subjectId,
      category: widget.category,
    );
    final data = await _repo.listBySubject(
      subjectId: widget.subjectId,
      category: widget.category,
    );
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_items.isEmpty) {
      return const EmptyState(
        title: 'Aucun document',
        subtitle: 'Aucun contenu disponible.',
      );
    }
    final grouped = <String, List<ExamEntry>>{};
    for (final e in _items) {
      grouped.putIfAbsent(e.semester ?? 'Session', () => []).add(e);
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.subjectLabel)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.l),
        children: grouped.entries
            .map(
              (g) => Container(
                margin: const EdgeInsets.only(bottom: AppSpace.s),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Semestre: ${g.key}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  children: g.value
                      .map(
                        (e) => ListTile(
                          title: Text(
                            e.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            e.correctionUrl?.isNotEmpty == true
                                ? 'Avec correction'
                                : 'Sans correction',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textTertiary,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExamDetailPage(
                                title: e.title,
                                paperUrl: e.paperUrl,
                                correctionUrl: e.correctionUrl,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
