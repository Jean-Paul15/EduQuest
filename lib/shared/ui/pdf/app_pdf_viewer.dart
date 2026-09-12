import 'dart:async';
import 'dart:typed_data';
import 'package:eduquest/features/gamification/data/revision_tracker.dart';
import 'package:eduquest/features/offline/data/pdf_runtime_cache.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:eduquest/shared/security/sensitive_scope.dart';
import 'package:eduquest/shared/ui/pdf/pdf_toolbar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AppPdfViewer extends StatefulWidget {
  const AppPdfViewer({super.key, required this.url, required this.emptyLabel});
  final String url;
  final String emptyLabel;
  @override
  State<AppPdfViewer> createState() => _AppPdfViewerState();
}

class _AppPdfViewerState extends State<AppPdfViewer> {
  final _cache = PdfRuntimeCache();
  final _tracker = RevisionTracker();
  final _pdfCtrl = PdfViewerController();
  String? _error;
  List<int>? _bytes;
  bool _showToolbar = false;
  int _currentPage = 1;
  int _totalPages = 0;
  final _viewedPages = <int>{};
  late final DateTime _openedAt;
  bool _usingCache = false;
  bool? _online;
  bool _trackingClosed = false;
  bool _offlineBootstrapRequired = false;
  Timer? _watchdog;
  bool get _valid => widget.url.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _openedAt = _tracker.start();
    _boot();
  }
  @override
  void dispose() {
    _watchdog?.cancel();
    unawaited(_finishTracking());
    super.dispose();
  }
  void _onMarkComplete() => unawaited(_finishTracking());
  void _toggleToolbar() => setState(() => _showToolbar = !_showToolbar);
  void _onPageChanged(PdfPageChangedDetails d) => setState(() {
        _currentPage = d.newPageNumber;
        _viewedPages.add(d.newPageNumber);
      });

  void _onDocumentLoaded(PdfDocumentLoadedDetails d) {
    if (!mounted) return;
    setState(() {
      _currentPage = _pdfCtrl.pageNumber == 0 ? 1 : _pdfCtrl.pageNumber;
      _totalPages = d.document.pages.count;
      _viewedPages.add(_currentPage);
      _error = null;
    });
  }

  Future<void> _boot() async {
    if (!_valid) {
      return;
    }
    // Filet de sécurité : si la préparation ne se termine jamais (exception
    // silencieuse dans la chaîne de cache, appel plateforme qui ne répond pas),
    // on bascule sur un état d'erreur actionnable plutôt que de laisser le
    // squelette « Préparation du document… » à l'infini.
    _watchdog?.cancel();
    _watchdog = Timer(const Duration(seconds: 30), () {
      if (mounted &&
          _bytes == null &&
          _error == null &&
          !_offlineBootstrapRequired) {
        setState(() {
          _error =
              'Ce document met trop de temps à répondre. Vérifie ta connexion et réessaie.';
        });
      }
    });
    try {
      await _bootFlow();
    } catch (_) {
      if (mounted && _bytes == null && !_offlineBootstrapRequired) {
        setState(() {
          _error = 'Impossible de préparer ce document pour le moment.';
        });
      }
    } finally {
      _watchdog?.cancel();
    }
  }

  Future<void> _bootFlow() async {
    final online = await NetworkProbe.hasConnection();
    if (!mounted) return;
    _online = online;
    final cached = await _cache.load(widget.url);
    if (!mounted) return;
    if (cached != null && cached.isNotEmpty) {
      setState(() {
        _bytes = cached;
        _usingCache = true;
        _offlineBootstrapRequired = false;
      });
      if (online) unawaited(_sync());
      return;
    }
    if (!online) {
      setState(() {
        _offlineBootstrapRequired = true;
      });
      return;
    }
    final synced = await _cache.sync(widget.url);
    if (!mounted) return;
    if (synced != null && synced.isNotEmpty) {
      setState(() {
        _bytes = synced;
        _usingCache = true;
        _offlineBootstrapRequired = false;
      });
      return;
    }
    if (mounted) {
      setState(() {
        _error = 'Impossible de préparer ce document pour le moment.';
      });
    }
  }

  Future<void> _sync() async {
    if (!_valid) return;
    final synced = await _cache.sync(widget.url);
    if (mounted && synced != null) {
      setState(() {
        _bytes = synced;
        _usingCache = true;
        _offlineBootstrapRequired = false;
      });
    }
  }

  Future<void> _retry() async {
    setState(() {
      _error = null;
      _offlineBootstrapRequired = false;
      _bytes = null;
      _usingCache = false;
      _viewedPages.clear();
      _currentPage = 1;
      _totalPages = 0;
    });
    await _boot();
  }

  void _onLoadFail(PdfDocumentLoadFailedDetails d) =>
      setState(() => _error = d.description);

  Widget _pdfViewer() {
    if (_bytes == null || _bytes!.isEmpty) return _loadingView();
    return SfPdfViewer.memory(Uint8List.fromList(_bytes!),
      controller: _pdfCtrl, onPageChanged: _onPageChanged,
      onDocumentLoaded: _onDocumentLoaded,
      canShowPaginationDialog: true, enableDoubleTapZooming: true,
      onDocumentLoadFailed: _onLoadFail);
  }

  @override
  Widget build(BuildContext context) {
    return SensitiveScope(
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_valid) {
      return EmptyState(title: 'PDF indisponible', subtitle: widget.emptyLabel);
    }
    if (_offlineBootstrapRequired) {
      return EmptyState(
        title: 'Document non disponible hors ligne',
        subtitle:
            'Ouvre ce document une première fois avec Internet pour le garder sur cet appareil.',
        actionLabel: 'Réessayer',
        onAction: _retry,
      );
    }
    if (_error != null) {
      return EmptyState(
        title: 'Lecture impossible',
        subtitle: _error!,
        actionLabel: 'Réessayer',
        onAction: _retry,
      );
    }
    return GestureDetector(
      onTap: _toggleToolbar,
      child: Stack(children: [
        _pdfViewer(),
        if (_usingCache)
          Positioned(
            top: 12,
            right: 12,
            child: _statusPill(),
          ),
        if (_showToolbar && _totalPages > 0)
          Positioned(left: 0, right: 0, bottom: 0,
            child: PdfToolbar(controller: _pdfCtrl,
              currentPage: _currentPage, totalPages: _totalPages,
              viewedPages: _viewedPages, onMarkComplete: _onMarkComplete)),
      ]),
    );
  }

  Widget _loadingView() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Expanded(
          child: RuachSkeleton(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Préparation du document…',
          style: TextStyle(fontSize: 13),
        ),
      ],
    ),
  );

  Widget _statusPill() {
    final label = (_online ?? false) ? 'Disponible hors ligne' : 'Lecture hors ligne';
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _finishTracking() async {
    if (_trackingClosed) return;
    _trackingClosed = true;
    final seconds = DateTime.now().difference(_openedAt).inSeconds;
    await _tracker.stop(_openedAt);
    if (seconds > 0) {
      unawaited(AppAnalytics().track(
        'content_revision_closed',
        category: 'content',
        targetType: 'resource',
        targetId: widget.url,
        payload: {'duration_seconds': seconds},
      ));
    }
  }
}
