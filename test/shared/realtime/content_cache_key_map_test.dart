import 'package:eduquest/shared/realtime/cache_signal.dart';
import 'package:eduquest/shared/realtime/content_cache_key_map.dart';
import 'package:flutter_test/flutter_test.dart';

const _scope = ScopeContext(
  seriesId: 'S1',
  levelId: 'L1',
  countryId: 'C1',
  seriesCode: 'D',
  levelCode: 'TLE',
);

void main() {
  test('resources : cle chapitre par type + listes + video + feed', () {
    final t = ContentCacheKeys.targetsFor(
      const CacheSignal(hint: 'resources', ref: {'chapter_id': 'CH', 'type': 'pdf'}),
      _scope,
    );
    expect(t.exact, contains('chapter:res:S1:CH:pdf'));
    expect(t.exact, contains('learn:res:pdf'));
    expect(t.exact, contains('feed:TLE:D'));
    expect(t.exact, isNot(contains('videos:TLE:D'))); // type pdf -> pas videos
  });

  test('resources sans type : les 5 types + videos', () {
    final t = ContentCacheKeys.targetsFor(
      const CacheSignal(hint: 'resources', ref: {'chapter_id': 'CH'}),
      _scope,
    );
    expect(t.exact, contains('chapter:res:S1:CH:summary'));
    expect(t.exact, contains('videos:TLE:D'));
  });

  test('quiz_meta : les 5 cles du bundle', () {
    final t = ContentCacheKeys.targetsFor(
      const CacheSignal(hint: 'quiz_meta', ref: {'quiz_id': 'Q'}),
      _scope,
    );
    expect(t.exact, containsAll([
      'learn:qcm:v2:bundle:Q',
      'learn:qcm:v2:q:Q',
      'learn:qcm:v2:pool:Q',
      'learn:qcm:v2:groups:Q',
      'learn:qcm:v2:config:Q',
    ]));
  });

  test('chapters : liste des chapitres de la matiere + liste des matieres', () {
    final t = ContentCacheKeys.targetsFor(
      const CacheSignal(hint: 'chapters', ref: {'subject_id': 'SUB'}),
      _scope,
    );
    expect(t.exact, contains('learn:chapters:L1:S1:SUB'));
    expect(t.exact, contains('learn:subjects:course:L1:S1'));
  });

  test('exam_papers sans subject : prefixe exam:papers:', () {
    final t = ContentCacheKeys.targetsFor(
      const CacheSignal(hint: 'exam_papers'),
      _scope,
    );
    expect(t.prefixes, contains('exam:papers:'));
    expect(t.exact, contains('exam:subjects:national:C1:L1:S1'));
  });

  test('marketplace : prefixe market:', () {
    final t = ContentCacheKeys.targetsFor(const CacheSignal(hint: 'marketplace'), _scope);
    expect(t.prefixes, contains('market:'));
  });

  test('app_config avec cle : cle exacte cfg:<key>', () {
    final t = ContentCacheKeys.targetsFor(
      const CacheSignal(hint: 'app_config', ref: {'key': 'hub_modules'}),
      _scope,
    );
    expect(t.exact, contains('cfg:hub_modules'));
  });

  test('signal * : reset de tout le scope', () {
    final t = ContentCacheKeys.targetsFor(const CacheSignal(hint: '*'), _scope);
    expect(t.prefixes, containsAll(['chapter:', 'learn:', 'exam:', 'hub:', 'feed:']));
  });

  test('parsing broadcast + catch-up + namespace', () {
    final b = CacheSignal.fromBroadcast(const {
      'hint': 'quizzes',
      'op': 'DELETE',
      'ref': {'chapter_id': 'CH', 'quiz_id': 'Q'},
    });
    expect(b.hint, 'quizzes');
    expect(b.op, 'DELETE');
    expect(b.ref['quiz_id'], 'Q');
    expect(b.namespace, 'chapter');

    final c = CacheSignal.fromCatchupRow(const {
      'cache_hint': 'contests',
      'op': 'INSERT',
      'ref': {},
    });
    expect(c.hint, 'contests');
    expect(c.namespace, 'hub:contests');
    expect(const CacheSignal(hint: '*').isScopeReset, isTrue);
  });
}
