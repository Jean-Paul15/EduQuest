import 'dart:async';
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';
import 'package:eduquest/features/videos/data/video_filter_repository.dart';
import 'package:eduquest/features/videos/data/video_repository.dart';
import 'package:eduquest/features/videos/domain/chapter_video.dart';
import 'package:eduquest/features/videos/presentation/widgets/video_filters.dart';
import 'package:eduquest/features/videos/presentation/widgets/video_list_body.dart';
import 'package:eduquest/features/learning/presentation/pages/widgets/resource_actions.dart';
import 'package:eduquest/shared/ui/offline_content_guard.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});
  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage>
    with RealtimeRefreshable<VideosPage> {
  final _repo = VideoRepository();
  final _filters = VideoFilterRepository();

  @override
  List<String> get realtimeNamespaces => const ['chapter', 'video'];

  @override
  Future<void> reloadFromRealtime() async {
    await _refreshFilters();
    await _load(background: true, forceRefresh: true);
  }
  String _level = '', _serie = '';
  List<String> _levels = const [], _series = const [];
  List<ChapterVideo> _videos = const [];
  String? _error;
  bool _booting = true;
  bool _loading = false;
  bool _offlineWarned = false;
  int _loadEpoch = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final seeded = await _filters.peekBootstrap();
      if (seeded != null && mounted) {
        setState(() {
          _applyBootstrap(seeded);
          _booting = false;
        });
        unawaited(_load(background: true));
      }
      final hadFilterCache = seeded != null || await _filters.hasCache();
      final boot = seeded == null
          ? await _filters.bootstrap()
          : await _filters.refreshBootstrap();
      if (!mounted) return;
      setState(() {
        _applyBootstrap(boot);
        _booting = false;
        _error = null;
      });
      await _load(background: seeded != null, forceRefresh: !boot.fromCache);
      if (_levels.isEmpty && !_offlineWarned && !hadFilterCache) {
        await _warnOfflineVideos();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _booting = false;
        _error = 'Impossible de charger les filtres vidéos pour le moment.';
      });
    }
  }

  Future<void> _onLevelChanged(String level) async {
    if (level == _level) return;
    final series = await _filters.series(level);
    if (!mounted) return;
    setState(() {
      _level = level;
      _series = series;
      _serie = series.contains(_serie)
          ? _serie
          : (series.isEmpty ? '' : series.first);
    });
    await _load(forceRefresh: true);
  }

  Future<void> _onSerieChanged(String serie) async {
    if (serie == _serie) return;
    setState(() => _serie = serie);
    await _load(forceRefresh: true);
  }

  Future<void> _load({
    bool background = false,
    bool forceRefresh = false,
  }) async {
    if (_level.isEmpty) return;
    final request = ++_loadEpoch;
    final hadCache = await _repo.hasCache(_level, _serie);
    if (!mounted) return;
    if (!background || _videos.isEmpty) setState(() => _loading = true);
    final data = await _repo.byLevelAndSerie(
      levelCode: _level,
      serieCode: _serie,
      forceRefresh: forceRefresh,
    );
    if (!mounted || request != _loadEpoch) return;
    if (data.isEmpty && !hadCache && !_offlineWarned) {
      await _warnOfflineVideos();
      if (!mounted || request != _loadEpoch) return;
    }
    setState(() {
      _videos = data;
      _loading = false;
    });
  }

  Future<void> _openVideo(ChapterVideo v) async {
    await openVideoResource(context, title: v.title, url: v.url);
  }

  void _applyBootstrap(VideoFilterBootstrap boot) {
    _level = boot.level;
    _serie = boot.serie;
    _levels = boot.levels;
    _series = boot.series;
  }


  Future<void> _refreshFilters() async {
    final boot = await _filters.refreshBootstrap();
    if (!mounted) return;
    final changed =
        boot.level != _level ||
        boot.serie != _serie ||
        boot.levels.join('|') != _levels.join('|') ||
        boot.series.join('|') != _series.join('|');
    setState(() => _applyBootstrap(boot));
    if (changed) await _load(background: true, forceRefresh: true);
  }

  Future<void> _warnOfflineVideos() async {
    if (_offlineWarned || !mounted) return;
    _offlineWarned = await guardOfflineContent(
      context: context,
      contentLabel: 'les vidéos',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_booting && _levels.isEmpty) {
      return Scaffold(
        appBar: const RuachAppBar(title: 'Vidéos', showBack: true),
        body: const VideoRowSkeletonList(),
      );
    }
    if (_error != null && _levels.isEmpty) {
      return Scaffold(
        appBar: const RuachAppBar(title: 'Vidéos', showBack: true),
        body: RuachEmptyState(
          title: 'Vidéos indisponibles',
          subtitle: _error!,
          icon: PhosphorIconsRegular.warningCircle,
          actionLabel: 'Réessayer',
          onAction: _init,
        ),
      );
    }
    return Scaffold(
      appBar: const RuachAppBar(title: 'Vidéos', showBack: true),
      body: Column(
        children: [
          VideoFilters(
            level: _level,
            serie: _serie,
            levels: _levels,
            series: _series,
            onLevelChanged: _onLevelChanged,
            onSerieChanged: _onSerieChanged,
          ),
          Expanded(
            child: VideoListBody(
              loading: _loading && _videos.isEmpty,
              refreshing: _loading && _videos.isNotEmpty,
              videos: _videos,
              onRefresh: () => _load(forceRefresh: true),
              onVideoTap: _openVideo,
            ),
          ),
        ],
      ),
    );
  }
}
