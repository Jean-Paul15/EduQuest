import 'dart:io';
import 'package:eduquest/features/offline/data/encrypted_video_cache.dart';
import 'package:eduquest/features/offline/data/video_offline_repository.dart';
import 'package:eduquest/shared/sync/service_locator.dart' hide ConnectionState;
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/media/video_download_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:video_player/video_player.dart';
class NetworkMediaPlayer extends StatefulWidget {
  const NetworkMediaPlayer({super.key, required this.url, this.offlineRepository});
  final String url;
  final VideoOfflineRepository? offlineRepository;
  @override
  State<NetworkMediaPlayer> createState() => _NetworkMediaPlayerState();
}
class _NetworkMediaPlayerState extends State<NetworkMediaPlayer> {
  VideoPlayerController? _ctrl;
  late Future<void> _ready;
  VideoOfflineRepository get _repo =>
      widget.offlineRepository ?? VideoOfflineRepository(EncryptedVideoCache());
  bool _dl = false, _dling = false, _done = false;
  double _prog = 0;
  String? _tmp;
  String? _error;
  bool _offlineBootstrapRequired = false;

  VideoPlayerController? get _controller => _ctrl;

  @override
  void initState() { super.initState(); _ready = _init(); }
  @override
  void dispose() { _ctrl?.dispose();
    if (_tmp != null) {
      try { File(_tmp!).delete(); } catch (_) {}
    }
    super.dispose(); }
  Future<void> _init() async {
    try {
      _error = null;
      _offlineBootstrapRequired = false;
      _dl = await _repo.isDownloaded(widget.url);
      final prior = _ctrl;
      _tmp = _dl ? await _repo.prepareForPlayback(widget.url) : null;
      if (_tmp == null && !ServiceLocator().oracle.isOnline) {
        _offlineBootstrapRequired = true;
        _ctrl = null;
        await prior?.dispose();
        return;
      }
      final next = _tmp != null
          ? VideoPlayerController.file(File(_tmp!))
          : VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await next.initialize();
      await prior?.dispose();
      _ctrl = next;
      if (mounted) setState(() {});
    } catch (_) {
      _error = 'Impossible de préparer cette vidéo.';
      _ctrl = null;
    }
  }
  Future<void> _download() async {
    if (!ServiceLocator().oracle.canDownloadMedia) {
      ModernSnackbar.show(
        context,
        'Téléchargement disponible seulement en connexion stable et Wi‑Fi.',
        success: false,
      );
      return;
    }
    setState(() { _dling = true; _prog = 0; });
    final ok = await _repo.downloadVideo(widget.url, onProgress: (d, t) {
      if (mounted) setState(() => _prog = t > 0 ? d / t : 0);
    });
    if (!mounted) return;
    if (ok) { setState(() { _dling = false; _done = true; _dl = true; });
      ModernSnackbar.show(context, 'Vidéo enregistrée pour le hors-ligne.');
      Future.delayed(RuachMotion.statusAnim,
          () { if (mounted) setState(() => _done = false); }); }
    else {
      setState(() => _dling = false);
      ModernSnackbar.show(
        context,
        'Téléchargement impossible pour le moment.',
        success: false,
      );
    }
  }
  Future<void> _retry() async {
    _ctrl?.dispose();
    _ctrl = null;
    if (_tmp != null) {
      try { File(_tmp!).delete(); } catch (_) {}
      _tmp = null;
    }
    _error = null;
    _offlineBootstrapRequired = false;
    setState(() => _ready = _init());
    await _ready;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _ready,
    builder: (_, s) {
      if (s.connectionState != ConnectionState.done) return _loadingView(context);
      if (_offlineBootstrapRequired) {
        return RuachEmptyState(
          icon: PhosphorIconsRegular.wifiSlash,
          title: 'Vidéo non disponible hors ligne',
          subtitle:
              'Lance cette vidéo au moins une fois avec Internet ou télécharge-la sur une connexion stable.',
          actionLabel: 'Réessayer',
          onAction: _retry,
        );
      }
      if (_error != null) {
        return RuachEmptyState(
          icon: PhosphorIconsRegular.warningCircle,
          title: 'Lecture impossible',
          subtitle: _error!,
          actionLabel: 'Réessayer',
          onAction: _retry,
        );
      }
      final ctrl = _controller;
      if (ctrl == null) {
        return RuachEmptyState(
          icon: PhosphorIconsRegular.video,
          title: 'Vidéo indisponible',
          subtitle: 'Impossible de charger ce média pour le moment.',
          actionLabel: 'Réessayer',
          onAction: _retry,
        );
      }
      return Padding(
        padding: const EdgeInsets.all(RuachSpace.s4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(RuachRadius.xl),
            child: DecoratedBox(
              decoration: const BoxDecoration(color: RuachColors.ink50),
              child: AspectRatio(
                aspectRatio: ctrl.value.aspectRatio == 0 ? 16 / 9 : ctrl.value.aspectRatio,
                child: Stack(children: [
                  Positioned.fill(child: VideoPlayer(ctrl)),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _statusPill(context),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      iconSize: 58,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: .35),
                        shape: const CircleBorder(),
                      ),
                      onPressed: () => setState(() => ctrl.value.isPlaying
                          ? ctrl.pause() : ctrl.play()),
                      icon: Icon(
                        ctrl.value.isPlaying
                            ? PhosphorIconsFill.pauseCircle
                            : PhosphorIconsFill.playCircle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: RuachSpace.s3),
          if (!_dl || _dling || _done)
            VideoDownloadBar(
              isDownloading: _dling,
              progress: _prog,
              isComplete: _done,
              onDownload: _download,
            ),
        ]),
      );
    },
  );

  Widget _loadingView(BuildContext context) => Padding(
    padding: const EdgeInsets.all(RuachSpace.s4),
    child: Column(
      children: [
        Expanded(
          child: RuachSkeleton(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(RuachRadius.xl),
              ),
            ),
          ),
        ),
        const SizedBox(height: RuachSpace.s3),
        const Text('Préparation de la vidéo…'),
      ],
    ),
  );

  Widget _statusPill(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: .38),
      borderRadius: BorderRadius.circular(RuachRadius.full),
      border: Border.all(color: Colors.white.withValues(alpha: .12)),
    ),
    child: Text(
      _dl
          ? (ServiceLocator().oracle.isOnline
              ? 'Disponible hors ligne'
              : 'Lecture hors ligne')
          : 'Streaming',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
