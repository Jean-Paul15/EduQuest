import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/features/videos/data/video_filter_repository.dart';
import 'package:eduquest/features/videos/data/video_repository.dart';
import 'package:eduquest/features/videos/domain/chapter_video.dart';
import 'package:eduquest/features/videos/presentation/widgets/video_item_tile.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/media/app_media_player_page.dart';
import 'package:eduquest/shared/ui/media/youtube_url_parser.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';

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
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final p = await UserProfileRepository().load();
    final levels = await _filters.levels();
    final level = levels.contains(p.levelCode) ? p.levelCode : levels.first;
    final series = await _filters.series(level);
    final serie = series.contains(p.serieCode) ? p.serieCode : series.first;
    if (!mounted) return;
    setState(() {
      _level = level;
      _serie = serie;
      _levels = levels;
      _series = series;
    });
    await _load();
  }

  Future<void> _onLevelChanged(String level) async {
    final series = await _filters.series(level);
    if (!mounted) return;
    setState(() {
      _level = level;
      _series = series;
      _serie = series.first;
    });
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _repo.byLevelAndSerie(
      levelCode: _level,
      serieCode: _serie,
    );
    if (!mounted) return;
    setState(() {
      _videos = data;
      _loading = false;
    });
  }

  Future<void> _openVideo(ChapterVideo v) async {
    final yt = isYoutubeUrl(v.url);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AppMediaPlayerPage(title: v.title, url: v.url, isYoutube: yt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_levels.isEmpty || _series.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Videos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpace.l),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    initialValue: _level,
                    items: _levels
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => _onLevelChanged('$v'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.s),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.s),
                Expanded(
                  child: DropdownButtonFormField(
                    initialValue: _serie,
                    items: _series
                        .map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text('Serie $v'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() => _serie = '$v');
                      _load();
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.s),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _videos.isEmpty
                ? EmptyState(
                    title: 'Aucune video',
                    subtitle: 'Essaie une autre classe.',
                    icon: Icons.ondemand_video_outlined,
                    actionLabel: 'Recharger',
                    onAction: _load,
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.l,
                      ),
                      children: _videos
                          .map(
                            (v) => VideoItemTile(
                              video: v,
                              onTap: () => _openVideo(v),
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
