import 'package:supabase_flutter/supabase_flutter.dart';

const _contentBucket = 'eduquest-content';

/// Résout un `storage_path` (chemin relatif au bucket public
/// `eduquest-content`, ex. `courses/anglais/terminale/.../course-v1.pdf`) en
/// URL publique complète et chargeable. Idempotent : si `path` est déjà une
/// URL absolue (contenu externe, ou déjà résolu), la retourne telle quelle.
///
/// Sans cette résolution, `storage_path` est utilisé tel quel comme URL par
/// plusieurs repositories -- un chemin relatif n'est jamais chargeable en
/// HTTP direct, d'où les PDF/vidéos de cours qui ne chargent jamais.
String? resolveContentUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return Supabase.instance.client.storage.from(_contentBucket).getPublicUrl(path);
}
