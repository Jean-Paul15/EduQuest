import 'package:eduquest/shared/ui/media/youtube_url_parser.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeMediaPlayer extends StatefulWidget {
  const YoutubeMediaPlayer({super.key, required this.url});
  final String url;

  @override
  State<YoutubeMediaPlayer> createState() => _YoutubeMediaPlayerState();
}

class _YoutubeMediaPlayerState extends State<YoutubeMediaPlayer> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final id = parseYoutubeId(widget.url);
    if (id != null && id.isNotEmpty) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: id,
        params: const YoutubePlayerParams(showFullscreenButton: true),
      );
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null) {
      return const EmptyState(
        title: 'Lien YouTube invalide',
        subtitle: 'Impossible de lire cette vidéo.',
      );
    }
    return YoutubePlayer(controller: c);
  }
}
