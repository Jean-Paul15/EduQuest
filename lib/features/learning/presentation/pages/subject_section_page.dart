import 'dart:async';
import 'package:eduquest/features/access/data/access_repository.dart' show AccessState;
import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/learning/data/exam_repository.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/data/learning_scope_repository.dart';
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
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';

typedef SubjectSectionLoader =
    Future<({
      List<LearningSubject> items,
      AccessState access,
      Map<String, String> learningAccess,
      bool seriesMissing,
    })>
    Function();

class SubjectSectionPage extends StatefulWidget {
  const SubjectSectionPage({
    super.key,
    required this.section,
    this.loader,
  });
  final LearningSection section;
  final SubjectSectionLoader? loader;
  @override
  State<SubjectSectionPage> createState() => _SubjectSectionPageState();
}

class _SubjectSectionPageState extends State<SubjectSectionPage>
    with AutomaticKeepAliveClientMixin, RealtimeRefreshable<SubjectSectionPage> {
  @override
  List<String> get realtimeNamespaces => const ['learn'];

  @override
  Future<void> reloadFromRealtime() => _load();

  final _catalog = LearningCatalogRepository(), _exams = ExamRepository(), _warmup = LearningWarmupService();
  final _notif = NotificationService(), _configRepo = AppConfigRepository();
  List<LearningSubject> _items = const [];
  bool _loading = true;
  String? _openingId;
  bool _offlineWarned = false;
  bool _offlineEmpty = false;
  String? _emptyTitle;
  String? _emptySubtitle;
  Map<String, String> _learningAccess = const {};
  AccessState _access = const AccessState(
    tier: 'FREE_LIGHT',
    hasAccess: true,
    expiresAt: null,
  );
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    if (widget.loader != null) {
      final state = await widget.loader!();
      if (!mounted) return;
      setState(() {
        _items = state.items;
        _loading = false;
        _access = state.access;
        _learningAccess = state.learningAccess;
        _offlineEmpty = false;
        _emptyTitle = state.seriesMissing ? 'Série requise' : null;
        _emptySubtitle = state.seriesMissing
            ? 'Cette classe n’a pas encore de série active ciblable pour ${widget.section.label}.'
            : null;
      });
      return;
    }
    final scope = await LearningScopeRepository().current();
    if (mounted && _items.isEmpty) {
      setState(() {
        _loading = true;
        _offlineEmpty = false;
        _emptyTitle = null;
        _emptySubtitle = null;
      });
    }
    await loadSectionSubjects(
      section: widget.section, examRepo: _exams, catalogRepo: _catalog,
      configRepo: _configRepo, warmupService: _warmup,
      isMounted: () => mounted,
      onDataLoaded: (items, access, learningAccess) {
        if (mounted) {
          setState(() {
            _items = items;
            _loading = false;
            _access = access;
            _learningAccess = learningAccess;
            if ((scope?.seriesId?.isEmpty ?? true) || scope?.seriesId == null) {
              _emptyTitle = 'Série requise';
              _emptySubtitle =
                  'Cette classe n’a pas encore de série active ciblable pour ${widget.section.label}.';
            }
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
    setState(() => _offlineEmpty = true);
    unawaited(_notif.sendOfflineContentWarning(label));
    await showOfflineBootstrapAlert(context, contentLabel: label);
  }
  ExamCategory? get _examCat => switch (widget.section) {
    LearningSection.exams => ExamCategory.national,
    LearningSection.epreuves => ExamCategory.epreuve,
    LearningSection.mockExams => ExamCategory.mock,
    _ => null,
  };
  // 'forYou' n'atteint jamais cette page (LearningPageBody route ce cas vers
  // ReviewSectionPage) : la clé 'courses' n'est là que pour l'exhaustivité.
  String get _requiredTier => (_learningAccess[switch (widget.section) {
    LearningSection.courses => 'courses', LearningSection.exams => 'exams',
    LearningSection.epreuves => 'epreuves', LearningSection.mockExams => 'mockExams',
    LearningSection.videos => 'videos', LearningSection.youtube => 'youtube',
    LearningSection.forYou => 'courses',
  }] ?? 'HALF').toUpperCase();
  bool get _canOpenSection {
    if (_access.hasAccess == false || _access.isExpired) return false;
    if (_requiredTier == 'FREE') return true;
    if (_access.tier == 'ADMIN' || _access.tier == 'CAMPAIGN_FREE') {
      return true;
    }
    if (_requiredTier == 'FULL') return _access.isFullLike;
    if (_requiredTier == 'HALF') return _access.isHalfLike;
    return _access.canConsume('standard');
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SubjectSectionBody(
      loading: _loading, items: _items, sectionLabel: widget.section.label,
      offlineEmpty: _offlineEmpty,
      isExam: _examCat != null,
      emptyTitle: _emptyTitle,
      emptySubtitle: _emptySubtitle,
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
