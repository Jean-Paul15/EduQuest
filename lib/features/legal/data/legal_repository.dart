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

  /// Dernière version acceptée par l'utilisateur connecté pour ce [docType],
  /// ou `null` s'il n'a jamais accepté (ou n'est pas connecté).
  Future<({String version, DateTime acceptedAt})?> latestAccepted(
    String docType,
  ) async {
    if (!Env.hasSupabase) return null;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await Supabase.instance.client
        .from('user_legal_consents')
        .select('doc_version,accepted_at')
        .eq('profile_id', uid)
        .eq('doc_type', docType)
        .order('accepted_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return null;
    return (
      version: '${row['doc_version']}',
      acceptedAt: DateTime.parse('${row['accepted_at']}'),
    );
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

  /// Dernier recours si aucune version n'a jamais pu être chargée ni mise en
  /// cache (voir [_fromLocal]) — à resynchroniser avec la version active en
  /// base à chaque nouvelle publication de CGU/politique de confidentialité.
  LegalDocument _fallback(String type) {
    final isTerms = type == 'terms';
    final title = isTerms
        ? 'Conditions d’utilisation RuachEdu'
        : 'Politique de confidentialité RuachEdu';
    final body = isTerms
        ? '''
## Conditions d’utilisation de RuachEdu

En utilisant RuachEdu, édité par RuachNova Group SARL, tu acceptes les règles de la
plateforme. Le Service est disponible dans plusieurs pays et ne propose aucun paiement
intégré : l'accès dépend d'un ticket acheté sur un site externe.

### 1. Compte
- Les informations du profil doivent être exactes.
- Le compte est personnel et ne doit pas être partagé.

### 2. Utilisation des contenus
- Les cours, corrigés et quiz sont réservés à l’apprentissage personnel.
- Toute copie, extraction ou revente non autorisée est interdite.

### 3. Accès et tickets
- L’accès peut dépendre du type de ticket actif (FULL/HALF) et de sa date d'expiration.
- Les conditions d’accès peuvent évoluer selon les campagnes.

### 4. Bon usage
- Les comportements abusifs peuvent entraîner une restriction d’accès.
- Le respect des autres utilisateurs est obligatoire.

### 5. Droit applicable
- Droit togolais (loi n°2019-014), avec un socle de garanties volontaire aligné sur les
  standards internationaux pour les utilisateurs des autres pays desservis.

Le texte complet et à jour est disponible en ligne dans l'application dès que la connexion
est rétablie.
'''
        : '''
## Politique de confidentialité de RuachEdu

RuachEdu, édité par RuachNova Group SARL, protège les données personnelles de ses
utilisateurs, quel que soit leur pays de résidence.

### 1. Données collectées
- Profil : nom, classe, série, téléphone (si fourni).
- Usage : progression, quiz, activités d’apprentissage, échanges avec l'assistant IA.

### 2. Finalités
- Fournir et personnaliser le Service.
- Améliorer l’expérience et le support.
- Sécuriser la plateforme.

### 3. Conservation et sécurité
- Les données sont stockées de manière sécurisée (Supabase), avec accès restreint par rôle.
- Purge automatique en cas d'inactivité prolongée d'un compte élève.

### 4. Tes droits
Tu disposes des droits d'accès, de rectification, d'effacement, d'opposition et de
portabilité sur tes données. Tu peux les exercer directement depuis la section « Mes
données » de l'application (Profil → Mes données), ou en écrivant à
support@ruachnova.com. Tu peux aussi saisir l'IPDCP (autorité togolaise de protection des
données) en cas de réclamation.

Le texte complet et à jour est disponible en ligne dans l'application dès que la connexion
est rétablie.
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
