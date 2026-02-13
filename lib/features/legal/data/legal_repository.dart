import 'package:eduquest/features/legal/domain/legal_document.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LegalRepository {
  final _local = LocalJsonCache();

  Future<LegalDocument> load(String type) async {
    if (!Env.hasSupabase) return await _fromLocal(type) ?? _fallback(type);
    try {
      final row = await Supabase.instance.client
          .from('legal_documents')
          .select('doc_type,version,title,body_md')
          .eq('doc_type', type)
          .eq('active', true)
          .order('published_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (row == null) return await _fromLocal(type) ?? _fallback(type);
      final d = LegalDocument(
        type: '${row['doc_type']}',
        version: '${row['version']}',
        title: '${row['title']}',
        body: '${row['body_md']}',
      );
      await _local.writeList('legal:$type', [
        {
          'type': d.type,
          'version': d.version,
          'title': d.title,
          'body': d.body,
        },
      ]);
      return d;
    } catch (_) {
      return await _fromLocal(type) ?? _fallback(type);
    }
  }

  Future<void> accept(LegalDocument d) async {
    if (!Env.hasSupabase) return;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    await Supabase.instance.client.from('user_legal_consents').upsert({
      'profile_id': uid,
      'doc_type': d.type,
      'doc_version': d.version,
      'locale': 'fr-TG',
    });
  }

  LegalDocument _fallback(String type) {
    final title = type == 'terms'
        ? 'Conditions d’utilisation'
        : 'Politique de confidentialité';
    return LegalDocument(
      type: type,
      version: '1.0.0',
      title: title,
      body: 'Document en cours de chargement.',
    );
  }

  Future<LegalDocument?> _fromLocal(String type) async {
    final rows = await _local.readList('legal:$type');
    if (rows == null || rows.isEmpty) return null;
    final r = rows.first;
    return LegalDocument(
      type: '${r['type']}',
      version: '${r['version']}',
      title: '${r['title']}',
      body: '${r['body']}',
    );
  }
}
