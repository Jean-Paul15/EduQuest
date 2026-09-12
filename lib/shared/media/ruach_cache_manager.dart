import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Singleton image cache manager with subdirectory-based organization.
///
/// Cache rules:
/// - 30 day TTL for covers / thumbnails / banners (default stalePeriod).
/// - 5000 max cached objects, approximating a 500 MB cap.
/// - Key format via [customKey]: `folder_entityId_versionHash`.
/// - Subdirectories `covers/`, `thumbnails/`, `avatars/`, `banners/`
///   are pre-created under the application support folder for manual
///   inspection. Actual cached files are managed by the built-in
///   [IOFileSystem] inside the `ruach_img_cache` temp directory.
class RuachCacheManager extends CacheManager {
  static final RuachCacheManager _instance = RuachCacheManager._();

  /// Public singleton accessor.
  // ignore: prefer_constructors_over_static_methods
  static RuachCacheManager get instance => _instance;

  static String customKey(String folder, String id, String version) =>
      '${folder}_${id}_$version';

  static const _subdirs = ['covers', 'thumbnails', 'avatars', 'banners'];

  RuachCacheManager._()
      : super(
          Config(
            'ruach_img_cache',
            stalePeriod: const Duration(days: 30),
            maxNrOfCacheObjects: 5000,
          ),
        ) {
    _ensureSubdirs();
  }

  void _ensureSubdirs() {
    // Purement indicatif (inspection manuelle du cache) -- jamais bloquant
    // pour le chargement d'images, qui passe par le CacheManager sous-jacent
    // et fonctionne indépendamment. Une exception ici (web sans
    // implémentation path_provider, permissions refusées...) ne doit jamais
    // rester non interceptée : un rejet de Future non capturé au niveau
    // racine peut interrompre le rendu de tout l'écran qui a demandé ce
    // singleton (observé en conditions réelles sur l'écran de quiz).
    getApplicationSupportDirectory().then((dir) async {
      final base = Directory(p.join(dir.path, 'ruach_img_cache'));
      if (!await base.exists()) await base.create(recursive: true);
      for (final sub in _subdirs) {
        final d = Directory(p.join(base.path, sub));
        if (!await d.exists()) await d.create(recursive: true);
      }
    }).catchError((_) {});
  }
}
