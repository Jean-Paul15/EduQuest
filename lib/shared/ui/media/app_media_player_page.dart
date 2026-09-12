import 'dart:async';
import 'package:eduquest/features/gamification/data/revision_tracker.dart';
import 'package:eduquest/shared/security/sensitive_scope.dart';
import 'package:eduquest/shared/ui/media/network_media_player.dart';
import 'package:eduquest/shared/ui/media/youtube_media_player.dart';
import 'package:eduquest/shared/ui/media/youtube_url_parser.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';

class AppMediaPlayerPage extends StatefulWidget {
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
  State<AppMediaPlayerPage> createState() => _AppMediaPlayerPageState();
}

class _AppMediaPlayerPageState extends State<AppMediaPlayerPage> {
  final _tracker = RevisionTracker();
  late final DateTime _openedAt;
  bool get _playYoutube => widget.isYoutube || isYoutubeUrl(widget.url);

  @override
  void initState() {
    super.initState();
    _openedAt = _tracker.start();
  }

  @override
  void dispose() {
    unawaited(_tracker.stop(_openedAt));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SensitiveScope(
      child: Scaffold(
        appBar: RuachAppBar(title: widget.title, showBack: true),
        body: _playYoutube
            ? YoutubeMediaPlayer(url: widget.url)
            : NetworkMediaPlayer(url: widget.url),
      ),
    );
  }
}
