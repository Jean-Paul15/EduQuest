import 'dart:async';
import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/offline/data/encrypted_video_cache.dart';
import 'package:eduquest/features/offline/data/pdf_runtime_cache.dart';
import 'package:eduquest/features/offline/data/video_offline_repository.dart';
import 'package:eduquest/features/learning/data/learning_content_repository.dart';
import 'package:eduquest/features/learning/domain/learning_item.dart';
import 'package:eduquest/features/learning/presentation/pages/resource_list_tile.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/sync/service_locator.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/media/youtube_url_parser.dart';
import 'package:eduquest/shared/ui/offline_content_guard.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';

class ResourceLearningPage extends StatefulWidget {
  const ResourceLearningPage({
    super.key,
    required this.type,
    required this.emptyLabel,
  });
  final String type;
  final String emptyLabel;
  @override
  State<ResourceLearningPage> createState() => _ResourceLearningPageState();
}

class _ResourceLearningPageState extends State<ResourceLearningPage>
    with RealtimeRefreshable<ResourceLearningPage> {
  @override
  List<String> get realtimeNamespaces => const ['chapter'];

  @override
  Future<void> reloadFromRealtime() => _load();

  final _repo = LearningContentRepository();
  final _analytics = AppAnalytics();
  final _pdf = PdfRuntimeCache();
  final _videos = VideoOfflineRepository(EncryptedVideoCache());
  List<LearningItem> _items = const [];
  final Map<String, ({bool ready, String? label})> _offlineStatus = {};
  bool _loading = true;
  bool _offlineWarned = false;
  bool get _pdfMode =>
      widget.type == 'pdf' ||
      widget.type == 'exercise_set' ||
      widget.type == 'summary';
  bool get _videoMode => widget.type == 'video' || widget.type == 'youtube';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted && _items.isEmpty) setState(() => _loading = true);
    final items = await _repo.listResourceType(widget.type);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
    unawaited(
      _analytics.track(
        'resource_catalog_opened',
        category: 'resource',
        targetType: widget.type,
        payload: {'count': items.length},
      ),
    );
    unawaited(_loadOfflineStatus(items));
    if (items.isEmpty && !_offlineWarned) {
      _offlineWarned = await guardOfflineContent(
        context: context,
        contentLabel: 'ce contenu',
      );
    }
    if (_pdfMode && ServiceLocator().oracle.canDownloadMedia) {
      unawaited(_warmPdfs(items));
    }
  }

  Future<void> _loadOfflineStatus(List<LearningItem> items) async {
    if (!_pdfMode && !_videoMode) return;
    final rows = await Future.wait(
      items.map((item) async {
        final url = item.url;
        if (url == null || url.isEmpty) {
          return MapEntry(item.id, (ready: false, label: 'Lien indisponible'));
        }
        final ready = _pdfMode
            ? await _pdf.hasCached(url)
            : await _videos.isDownloaded(url);
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

  Future<void> _warmPdfs(List<LearningItem> items) async {
    for (final item in items.take(3)) {
      final url = item.url;
      if (url != null && url.isNotEmpty) await _pdf.sync(url);
    }
    await _loadOfflineStatus(items);
  }

  Future<void> _open(LearningItem item) async {
    final url = item.url;
    if (url == null || url.isEmpty) return;
    unawaited(
      _analytics.track(
        'resource_opened',
        category: 'resource',
        targetType: widget.type,
        targetId: item.id,
        payload: {'title': item.title},
      ),
    );
    if (_pdfMode) {
      await context.pushNamed(
        AppRoutes.pdfViewer,
        queryParameters: {
          'title': item.title,
          'url': url,
          'emptyLabel': widget.emptyLabel,
        },
      );
      return;
    }
    if (_videoMode) {
      final yt = isYoutubeUrl(url);
      await context.pushNamed(
        AppRoutes.mediaPlayer,
        queryParameters: {
          'title': item.title,
          'url': url,
          'isYoutube': yt.toString(),
        },
      );
      return;
    }
    await context.pushNamed(
      AppRoutes.webView,
      queryParameters: {
        'title': item.title,
        'url': url,
        'emptyLabel': widget.emptyLabel,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading(context);
    if (_items.isEmpty) {
      return EmptyState(
        title: 'Section vide',
        subtitle: widget.emptyLabel,
        icon: PhosphorIconsRegular.bookOpen,
        actionLabel: 'Actualiser',
        onAction: _load,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(RuachSpace.s4),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
        itemBuilder: (_, i) => ResourceListTile(
          item: _items[i],
          isPdfMode: _pdfMode,
          isVideoMode: _videoMode,
          offlineLabel: _offlineStatus[_items[i].id]?.label,
          offlineReady: _offlineStatus[_items[i].id]?.ready ?? false,
          onTap: () => _open(_items[i]),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(RuachSpace.s4),
    itemCount: 4,
    separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
    itemBuilder: (_, __) => RuachSkeleton(
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RuachRadius.lg),
        ),
      ),
    ),
  );
}
