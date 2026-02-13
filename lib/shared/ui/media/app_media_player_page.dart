import 'package:eduquest/shared/ui/media/network_media_player.dart';
import 'package:eduquest/shared/ui/media/youtube_media_player.dart';
import 'package:flutter/material.dart';

class AppMediaPlayerPage extends StatelessWidget {
  const AppMediaPlayerPage({
    super.key,
    required this.title,
    required this.url,
    required this.isYoutube,
  });
  final String title;
  final String url;
  final bool isYoutube;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: isYoutube
          ? YoutubeMediaPlayer(url: url)
          : NetworkMediaPlayer(url: url),
    );
  }
}
