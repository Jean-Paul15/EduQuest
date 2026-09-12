import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:eduquest/shared/media/ruach_cache_manager.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';

/// Image widget backed by [RuachCacheManager] with skeleton placeholder
/// and a colored fallback showing the first letter of [placeholderText].
class RuachCachedImage extends StatelessWidget {
  const RuachCachedImage({
    super.key,
    required this.imageUrl,
    required this.folder,
    required this.entityId,
    required this.versionHash,
    this.width, this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderText = '',
  });

  final String imageUrl, folder, entityId, versionHash, placeholderText;
  final double? width, height, borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final key = RuachCacheManager.customKey(folder, entityId, versionHash);
    final r = borderRadius ?? RuachRadius.md;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CachedNetworkImage(
      cacheKey: key, imageUrl: imageUrl,
      cacheManager: RuachCacheManager.instance,
      width: width, height: height, fit: fit,
      placeholder: (_, __) => _skeleton(r, isDark),
      errorWidget: (_, __, ___) => _fallback(r),
    );
  }

  Widget _skeleton(double r, bool isDark) {
    return RuachSkeleton(child: Container(
    width: width, height: height,
    decoration: BoxDecoration(
      color: isDark ? RuachColors.ink400 : RuachColors.cream200,
      borderRadius: BorderRadius.circular(r))));
  }

  Widget _fallback(double r) {
    final letter =
        placeholderText.isNotEmpty ? placeholderText[0].toUpperCase() : '?';
    return Container(width: width, height: height,
      decoration: BoxDecoration(
        color: RuachColors.gold500.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(r)),
      alignment: Alignment.center,
      child: Text(letter, style: TextStyle(
        color: RuachColors.gold500,
        fontSize: (height ?? 48) * 0.4,
        fontWeight: FontWeight.w600)));
  }
}
