import 'package:eduquest/features/learning/domain/pdf_lesson.dart';
import 'package:eduquest/features/offline/data/encrypted_pdf_cache.dart';
import 'package:eduquest/features/offline/data/pdf_offline_repository.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PdfLessonRepository {
  PdfLessonRepository()
      : _storage = const FlutterSecureStorage(),
        _offline = PdfOfflineRepository(EncryptedPdfCache());
  final FlutterSecureStorage _storage;
  final PdfOfflineRepository _offline;

  Future<List<PdfLesson>> listPublished() async {
    if (!Env.hasSupabase) return const [];
    final rows = await Supabase.instance.client
        .from('resources')
        .select('id,title,version,storage_path,external_url')
        .eq('type', 'pdf')
        .eq('published', true);
    return (rows as List).map((r) {
      final e = Map<String, dynamic>.from(r as Map);
      final url = e['storage_path']?.toString() ?? e['external_url']?.toString() ?? '';
      return PdfLesson(id: '${e['id']}', title: '${e['title']}', version: '${e['version']}', url: url);
    }).where((e) => e.url.isNotEmpty).toList();
  }

  Future<void> warmAndRefresh(List<PdfLesson> lessons) async {
    for (final l in lessons) {
      final key = 'pdf_ver_${l.id}';
      final old = await _storage.read(key: key);
      final ok = await _offline.syncPdf(resourceId: l.id, pdfUrl: l.url, version: l.version, oldVersion: old);
      if (ok) await _storage.write(key: key, value: l.version);
    }
  }

  Future<bool> isAvailableOffline(PdfLesson l) async {
    if (await _offline.hasPdf(l.id, l.version)) return true;
    final old = await _storage.read(key: 'pdf_ver_${l.id}');
    if (old == null) return false;
    return _offline.hasPdf(l.id, old);
  }
}
