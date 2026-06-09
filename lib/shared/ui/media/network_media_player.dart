import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NetworkMediaPlayer extends StatefulWidget {
  const NetworkMediaPlayer({super.key, required this.url});
  final String url;

  @override
  State<NetworkMediaPlayer> createState() => _NetworkMediaPlayerState();
}

class _NetworkMediaPlayerState extends State<NetworkMediaPlayer> {
  late final VideoPlayerController _controller;
  late final Future<void> _ready;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _ready = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() => setState(
    () =>
        _controller.value.isPlaying ? _controller.pause() : _controller.play(),
  );

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _ready,
    builder: (_, s) => s.connectionState != ConnectionState.done
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio == 0
                  ? 16 / 9
                  : _controller.value.aspectRatio,
              child: Stack(
                children: [
                  VideoPlayer(_controller),
                  Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      iconSize: 56,
                      onPressed: _toggle,
                      icon: Icon(
                        _controller.value.isPlaying
                            ? PhosphorIconsRegular.pauseCircle
                            : PhosphorIconsRegular.playCircle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
  );
}
