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
    final isTerms = type == 'terms';
    final title = isTerms
        ? 'Conditions d’utilisation'
        : 'Politique de confidentialité';
    final body = isTerms
        ? '''
## Conditions d’utilisation

En utilisant RuachNova, tu acceptes les règles de la plateforme.

### 1. Compte
- Les informations du profil doivent être exactes.
- Le compte est personnel et ne doit pas être partagé.

### 2. Utilisation des contenus
- Les cours, corrigés et quiz sont réservés à l’apprentissage.
- Toute copie ou revente non autorisée est interdite.

### 3. Accès et tickets
- L’accès peut dépendre du type de ticket actif.
- Les conditions d’accès peuvent évoluer selon les campagnes.

### 4. Bon usage
- Les comportements abusifs peuvent entraîner une restriction d’accès.
- Le respect des autres utilisateurs est obligatoire.
'''
        : '''
## Politique de confidentialité

RuachNova protège les données personnelles des utilisateurs.

### 1. Données collectées
- Profil: nom, classe, série, téléphone (si fourni).
- Usage: progression, quiz, activités d’apprentissage.

### 2. Finalités
- Personnaliser les contenus.
- Améliorer l’expérience et le support.
- Sécuriser la plateforme.

### 3. Conservation et sécurité
- Les données sont stockées de manière sécurisée.
- L’accès est limité aux services autorisés.

### 4. Droits utilisateur
- Tu peux demander la modification ou la suppression de tes données
  via le support.
''';
    return LegalDocument(
      type: type,
      version: '1.0.0',
      title: title,
      body: body,
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
