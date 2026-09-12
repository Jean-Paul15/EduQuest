import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../domain/quiz_content_block.dart';
import '../constants.dart';
import '../quiz_icons.dart';

/// Rendu d'image avec cache, skeleton loader et gestion d'alt.
class ImageBlockRenderer extends StatelessWidget {
  const ImageBlockRenderer(this.block, {super.key, this.cacheManager, this.onLoadFailed});
  final ImageBlock block;

  /// Cache partagé injecté par l'hôte (ex. RuachCacheManager — clé
  /// versionnée, TTL, purge communs avec le reste de l'app). `null` = cache
  /// par défaut de `cached_network_image`.
  final CacheManager? cacheManager;

  /// Notifie l'hôte qu'une image n'a pas pu être chargée (analytics
  /// `image_load_failed`, §14.1 du RUACHEDU_QUIZ_ENGINE.md).
  final ValueChanged<String>? onLoadFailed;

  @override
  Widget build(BuildContext context) {
    final ratio = block.aspectRatio ?? 16 / 9;
    return Semantics(
      label: block.alt,
      button: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: [
          FractionallySizedBox(
            widthFactor: (block.widthPercent.clamp(10, 100)) / 100,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _openPreview(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: ratio,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: block.url,
                          cacheManager: cacheManager,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => _ImageSkeleton(ratio: ratio),
                          errorWidget: (_, __, ___) => _onError(alt: block.alt),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: ink900.withValues(alpha: .72),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: gold500.withValues(alpha: .25)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(QuizIcons.zoomIn, size: 14, color: cream900),
                                  SizedBox(width: 4),
                                  Text(
                                    'Zoom',
                                    style: TextStyle(
                                      color: cream900,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (block.caption != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(block.caption!, style: TextStyle(
                  color: cream700, fontSize: 12, fontStyle: FontStyle.italic)),
            ),
        ]),
      ),
    );
  }

  /// Signale l'échec au frame suivant (jamais pendant `build`) puis affiche
  /// le fallback visuel — `analytics.trackImageLoadFailed` (§14.1).
  Widget _onError({required String alt}) {
    final failed = onLoadFailed;
    if (failed != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => failed(block.url));
    }
    return _ImageError(alt: alt);
  }

  Future<void> _openPreview(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: ink900,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: CachedNetworkImage(
                imageUrl: block.url,
                cacheManager: cacheManager,
                fit: BoxFit.contain,
                placeholder: (_, __) => _ImageSkeleton(
                  ratio: block.aspectRatio ?? 16 / 9,
                ),
                errorWidget: (_, __, ___) => _onError(alt: block.alt),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: ink900.withValues(alpha: .75),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(),
                icon: Icon(QuizIcons.close, color: cream900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSkeleton extends StatelessWidget {
  const _ImageSkeleton({required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: surfaceBase,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 12,
            decoration: BoxDecoration(
              color: surfaceStroke,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: ratio > 1 ? 14 : 12,
            decoration: BoxDecoration(
              color: surfaceStroke,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 120,
            height: 12,
            decoration: BoxDecoration(
              color: gold500.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError({required this.alt});

  final String alt;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: surfaceBase,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(QuizIcons.brokenImage, color: cream700, size: 30),
          const SizedBox(height: 8),
          Text(
            alt,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(color: cream700, fontSize: 12, height: 1.35),
          ),
        ],
      ),
    );
  }
}
