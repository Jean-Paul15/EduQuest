import 'dart:async';
import 'package:eduquest/features/offline/data/pdf_runtime_cache.dart';
import 'package:eduquest/features/learning/data/chapter_content_repository.dart';
import 'package:eduquest/features/learning/domain/chapter_resource.dart';
import 'package:eduquest/features/notifications/data/notification_service.dart';
import 'package:eduquest/shared/network/network_probe.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/media/app_media_player_page.dart';
import 'package:eduquest/shared/ui/media/youtube_url_parser.dart';
import 'package:eduquest/shared/ui/offline_bootstrap_alert.dart';
import 'package:eduquest/shared/ui/pdf/app_pdf_viewer.dart';
import 'package:eduquest/shared/ui/web/app_webview_page.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';

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
    with AutomaticKeepAliveClientMixin {
  final _repo = ChapterContentRepository();
  final _pdf = PdfRuntimeCache();
  final _notif = NotificationService();
  List<ChapterResource> _items = const [];
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
    if (data.isEmpty) {
      await _warnIfOfflineBootstrap(hadCache: hadCache, label: 'ce contenu');
    }
    if (_pdfMode) {
      for (final r in data.take(3)) {
        unawaited(_pdf.sync(r.url));
      }
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

  Future<void> _open(ChapterResource r) async {
    if (_pdfMode) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AppPdfViewerPage(
            title: r.title,
            url: r.url,
            emptyLabel: widget.emptyLabel,
          ),
        ),
      );
      return;
    }
    if (_videoMode) {
      final yt = parseYoutubeId(r.url) != null;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AppMediaPlayerPage(title: r.title, url: r.url, isYoutube: yt),
        ),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppWebViewPage(
          title: r.title,
          url: r.url,
          emptyLabel: widget.emptyLabel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) {
      return EmptyState(title: 'Rien a afficher', subtitle: widget.emptyLabel);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpace.l),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpace.s),
      itemBuilder: (_, i) {
        final e = _items[i];
        final icon = _pdfMode
            ? Icons.picture_as_pdf_rounded
            : _videoMode
            ? Icons.play_circle_outlined
            : Icons.open_in_browser_rounded;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: ListTile(
            title: Text(
              e.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(icon, color: AppColors.primary),
            onTap: () => _open(e),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
