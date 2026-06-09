import 'dart:async';
import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/learning/data/exam_repository.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/data/learning_warmup_service.dart';
import 'package:eduquest/features/learning/domain/exam_category.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/learning/domain/learning_subject.dart';
import 'package:eduquest/features/learning/presentation/pages/load_section_subjects.dart';
import 'package:eduquest/features/learning/presentation/pages/open_subject_navigation.dart';
import 'package:eduquest/features/learning/presentation/pages/subject_section_body.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:eduquest/shared/ui/offline_bootstrap_alert.dart';
import 'package:flutter/material.dart';

class SubjectSectionPage extends StatefulWidget {
  const SubjectSectionPage({super.key, required this.section});
  final LearningSection section;
  @override
  State<SubjectSectionPage> createState() => _SubjectSectionPageState();
}

class _SubjectSectionPageState extends State<SubjectSectionPage>
    with AutomaticKeepAliveClientMixin {
  final _catalog = LearningCatalogRepository(), _exams = ExamRepository(), _warmup = LearningWarmupService();
  final _notif = NotificationService(), _accessRepo = AccessRepository(), _configRepo = AppConfigRepository();
  List<LearningSubject> _items = const [];
  bool _loading = true;
  String? _openingId;
  bool _offlineWarned = false;
  Map<String, String> _learningAccess = const {};
  AccessState _access = const AccessState(tier: 'FREE', hasAccess: true, expiresAt: null);
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    if (mounted && _items.isEmpty) setState(() => _loading = true);
    await loadSectionSubjects(
      section: widget.section, examRepo: _exams, catalogRepo: _catalog,
      accessRepo: _accessRepo, configRepo: _configRepo, warmupService: _warmup,
      isMounted: () => mounted,
      onDataLoaded: (items, access, learningAccess) {
        if (mounted) {
          setState(() {
            _items = items; _loading = false; _access = access; _learningAccess = learningAccess;
          });
        }
      },
      warnOffline: _warnIfOffline,
    );
  }
  Future<void> _warnIfOffline({required bool hadCache, required String label}) async {
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
  String get _requiredTier => (_learningAccess[switch (widget.section) {
    LearningSection.courses => 'courses', LearningSection.exams => 'exams',
    LearningSection.epreuves => 'epreuves', LearningSection.mockExams => 'mockExams',
    LearningSection.videos => 'videos', LearningSection.youtube => 'youtube',
  }] ?? 'HALF').toUpperCase();
  bool get _canOpenSection {
    if (_access.hasAccess == false) return false;
    if (_requiredTier == 'FREE' || _access.tier == 'ADMIN' || _access.tier == 'CAMPAIGN_FREE') return true;
    const rank = {'FREE': 0, 'HALF': 1, 'FULL': 2};
    return (rank[_access.tier] ?? -1) >= (rank[_requiredTier] ?? 1);
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SubjectSectionBody(
      loading: _loading, items: _items, sectionLabel: widget.section.label,
      openingId: _openingId,
      onItemTap: (s) async {
        await openSubjectNavigation(
          context: context, subject: s, section: widget.section,
          examCategory: _examCat, canOpenSection: _canOpenSection,
          accessTier: _access.tier, requiredTier: _requiredTier,
          examRepo: _exams, catalogRepo: _catalog, warmupService: _warmup,
          onOpeningStarted: () { if (mounted) setState(() => _openingId = s.id); },
          onOpeningFinished: () { if (mounted) setState(() => _openingId = null); },
          isMounted: () => mounted,
        );
      },
      onRefresh: _load,
    );
  }
  @override
  bool get wantKeepAlive => true;
}
