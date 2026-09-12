import 'package:eduquest/shared/ui/media/youtube_url_parser.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/sync/service_locator.dart';
import 'package:eduquest/shared/ui/widgets/ruach_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
      return const RuachEmptyState(
        icon: PhosphorIconsRegular.linkBreak,
        title: 'Lien YouTube invalide',
        subtitle: 'Impossible de lire cette vidéo.',
      );
    }
    if (!ServiceLocator().oracle.isOnline) {
      return const RuachEmptyState(
        icon: PhosphorIconsRegular.wifiSlash,
        title: 'YouTube indisponible hors ligne',
        subtitle:
            'Cette vidéo nécessite Internet. Télécharge une ressource locale si tu veux la garder hors ligne.',
      );
    }
    return Padding(
      padding: const EdgeInsets.all(RuachSpace.s4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RuachRadius.xl),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: DecoratedBox(
            decoration: const BoxDecoration(color: RuachColors.ink50),
            child: Stack(
              children: [
                Positioned.fill(child: YoutubePlayer(controller: c)),
                Positioned(top: 12, right: 12, child: _statusPill(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusPill(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: .38),
      borderRadius: BorderRadius.circular(RuachRadius.full),
      border: Border.all(color: Colors.white.withValues(alpha: .12)),
    ),
    child: const Text(
      'Streaming',
      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}
