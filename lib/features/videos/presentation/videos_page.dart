import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/features/videos/data/video_filter_repository.dart';
import 'package:eduquest/features/videos/data/video_repository.dart';
import 'package:eduquest/features/videos/domain/chapter_video.dart';
import 'package:eduquest/features/videos/presentation/widgets/video_filters.dart';
import 'package:eduquest/features/videos/presentation/widgets/video_list_body.dart';
import 'package:eduquest/shared/ui/media/youtube_url_parser.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});
  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  final _repo = VideoRepository();
  final _filters = VideoFilterRepository();
  String _level = '', _serie = '';
  List<String> _levels = const [], _series = const [];
  List<ChapterVideo> _videos = const [];
  bool _loading = false;

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    final p = await UserProfileRepository().load();
    final levels = await _filters.levels();
    final level = levels.contains(p.levelCode) ? p.levelCode : levels.first;
    final series = await _filters.series(level);
    final serie = series.contains(p.serieCode) ? p.serieCode : series.first;
    if (!mounted) return;
    setState(() { _level = level; _serie = serie; _levels = levels; _series = series; });
    await _load();
  }

  Future<void> _onLevelChanged(String level) async {
    final series = await _filters.series(level);
    if (!mounted) return;
    setState(() { _level = level; _series = series; _serie = series.first; });
    await _load();
  }

  Future<void> _onSerieChanged(String serie) async { setState(() => _serie = serie); await _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _repo.byLevelAndSerie(levelCode: _level, serieCode: _serie);
    if (!mounted) return;
    setState(() { _videos = data; _loading = false; });
  }

  Future<void> _openVideo(ChapterVideo v) async {
    await context.pushNamed(AppRoutes.mediaPlayer, queryParameters: {
      'title': v.title,
      'url': v.url,
      'isYoutube': isYoutubeUrl(v.url).toString(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_levels.isEmpty || _series.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: const RuachAppBar(title: 'Videos'),
      body: Column(
        children: [
          VideoFilters(level: _level, serie: _serie, levels: _levels, series: _series, onLevelChanged: _onLevelChanged, onSerieChanged: _onSerieChanged),
          Expanded(child: VideoListBody(loading: _loading, videos: _videos, onRefresh: _load, onVideoTap: _openVideo)),
        ],
      ),
    );
  }
}
