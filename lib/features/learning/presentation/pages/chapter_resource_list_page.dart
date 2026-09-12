import 'dart:async';
import 'package:eduquest/features/offline/data/encrypted_video_cache.dart';
import 'package:eduquest/features/offline/data/pdf_runtime_cache.dart';
import 'package:eduquest/features/offline/data/video_offline_repository.dart';
import 'package:eduquest/features/learning/data/chapter_content_repository.dart';
import 'package:eduquest/features/learning/domain/chapter_resource.dart';
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';
import 'package:eduquest/shared/sync/service_locator.dart';
import 'package:flutter/material.dart';

import 'widgets/resource_actions.dart';
import 'widgets/resource_list_body.dart';

class ChapterResourceListPage extends StatefulWidget {
  const ChapterResourceListPage({
    super.key,
    required this.chapterId,
    required this.type,
    required this.emptyLabel,
    this.initialItems,
  });
  final String chapterId;
  final String type;
  final String emptyLabel;
  final List<ChapterResource>? initialItems;
  @override
  State<ChapterResourceListPage> createState() =>
      _ChapterResourceListPageState();
}

class _ChapterResourceListPageState extends State<ChapterResourceListPage>
    with AutomaticKeepAliveClientMixin, RealtimeRefreshable<ChapterResourceListPage> {
  @override
  List<String> get realtimeNamespaces => const ['chapter'];

  @override
  Future<void> reloadFromRealtime() => _load(background: true);

  final _repo = ChapterContentRepository();
  final _pdf = PdfRuntimeCache();
  final _videos = VideoOfflineRepository(EncryptedVideoCache());
  List<ChapterResource> _items = const [];
  final Map<String, ({bool ready, String? label})> _offlineStatus = {};
  bool _loading = true, _offlineWarned = false;
  bool get _pdfMode =>
      const {'pdf', 'exercise_set', 'summary'}.contains(widget.type);
  bool get _videoMode => const {'video', 'youtube'}.contains(widget.type);
  @override
  void initState() {
    super.initState();
    final seededFromNav = widget.initialItems;
    if (seededFromNav != null && seededFromNav.isNotEmpty) {
      _items = seededFromNav;
      _loading = false;
      _load(background: true);
      return;
    }
    final seeded = _repo.peekResources(
      chapterId: widget.chapterId,
      type: widget.type,
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
    final hadCache = await _repo.hasResourcesCache(
      chapterId: widget.chapterId,
      type: widget.type,
    );
    final data = await _repo.resources(
      chapterId: widget.chapterId,
      type: widget.type,
    );
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
    unawaited(_loadOfflineStatus(data));
    if (data.isEmpty && !_offlineWarned) {
      _offlineWarned = await warnIfOfflineBootstrap(
        context,
        hadCache: hadCache,
        label: 'ce contenu',
      );
    }
    if (_pdfMode && ServiceLocator().oracle.canDownloadMedia) {
      unawaited(_warmPdfs(data));
    }
  }

  Future<void> _loadOfflineStatus(List<ChapterResource> items) async {
    if (!_pdfMode && !_videoMode) return;
    final rows = await Future.wait(
      items.map((item) async {
        final ready = _pdfMode
            ? await _pdf.hasCached(item.url)
            : await _videos.isDownloaded(item.url);
        final label = _pdfMode
            ? (ready ? 'Disponible hors ligne' : 'Ouverture en ligne requise')
            : (ready
                  ? 'Téléchargée sur cet appareil'
                  : 'Streaming ou téléchargement');
        return MapEntry(item.id, (ready: ready, label: label));
      }),
    );
    if (!mounted) return;
    setState(() {
      _offlineStatus
        ..clear()
        ..addEntries(rows);
    });
  }

  Future<void> _warmPdfs(List<ChapterResource> items) async {
    for (final item in items.take(3)) {
      await _pdf.sync(item.url);
    }
    await _loadOfflineStatus(items);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ResourceListBody(
      items: _items,
      loading: _loading,
      isPdfMode: _pdfMode,
      isVideoMode: _videoMode,
      offlineStatus: _offlineStatus,
      emptyLabel: widget.emptyLabel,
      onRefresh: _load,
      onOpen: (r) => openResource(
        context,
        r,
        isPdfMode: _pdfMode,
        isVideoMode: _videoMode,
        emptyLabel: widget.emptyLabel,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
