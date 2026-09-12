import 'package:eduquest/features/gamification/domain/daily_quest.dart';
import 'package:eduquest/features/gamification/domain/gamification_repository_interface.dart';
import 'package:eduquest/features/gamification/domain/gamification_state.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/core/result.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/sync/service_locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GamificationRepository implements GamificationRepositoryInterface {
  final _local = LocalJsonCache();

  @override
  Future<Result<GamificationState>> loadState() async {
    final local = await _fromLocalState();
    if (!Env.hasSupabase) return success(local ?? _emptyState());
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return success(local ?? _emptyState());
    try {
      final row = await Supabase.instance.client
          .from('gamification_profiles')
          .select('xp,level,streak_days,best_streak')
          .eq('profile_id', uid)
          .maybeSingle();
      final out = row == null
          ? _emptyState()
          : GamificationState(
              xp: row['xp'] as int? ?? 0,
              level: row['level'] as int? ?? 1,
              streakDays: row['streak_days'] as int? ?? 0,
              bestStreak: row['best_streak'] as int? ?? 0,
            );
      await _local.writeList('gam:state', [
        {
          'xp': out.xp,
          'level': out.level,
          'streakDays': out.streakDays,
          'bestStreak': out.bestStreak,
        },
      ]);
      return success(out);
    } catch (e) {
      return success(local ?? _emptyState());
    }
  }

  @override
  Future<Result<List<DailyQuest>>> listDailyQuests() async {
    final local = await _fromLocalQuests();
    if (!Env.hasSupabase) return success(local);
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return success(local);
    try {
      final quests = await Supabase.instance.client
          .from('daily_quests')
          .select('id,code,label,xp_reward')
          .eq('active', true);
      final today = DateTime.now().toUtc().toIso8601String().split('T').first;
      final done = await Supabase.instance.client
          .from('quest_completions')
          .select('quest_id')
          .eq('profile_id', uid)
          .eq('completed_on', today);
      final doneIds = (done as List).map((e) => '${e['quest_id']}').toSet();
      final out = (quests as List)
          .map(
            (e) => DailyQuest(
              id: '${e['id']}',
              code: '${e['code'] ?? e['id']}',
              label: '${e['label']}',
              xpReward: e['xp_reward'] as int? ?? 0,
              completedToday: doneIds.contains('${e['id']}'),
            ),
          )
          .toList();
      await _local.writeList(
        'gam:quests',
        out
            .map(
              (e) => {
                'id': e.id,
                'code': e.code,
                'label': e.label,
                'xpReward': e.xpReward,
                'completedToday': e.completedToday,
              },
            )
            .toList(),
      );
      return success(out);
    } catch (_) {
      return success(local);
    }
  }

  @override
  Future<Result<String>> claimDailyCheckin() async {
    if (!Env.hasSupabase) return success('Check-in simulé (+20 XP).');
    try {
      final result = await Supabase.instance.client.rpc('claim_daily_checkin');
      final map = Map<String, dynamic>.from(result as Map);
      return success('${map['message'] ?? 'Action terminée.'}');
    } catch (_) {
      await ServiceLocator().sync.enqueueAndTryFlush(
        operation: 'RPC',
        targetTable: 'claim_daily_checkin',
        payload: <String, dynamic>{},
      );
      return success(
        'Check-in enregistré. Sera synchronisé dès le retour de connexion.',
      );
    }
  }

  @override
  Future<Result<String>> claimQuestByCode(String code) async {
    if (!Env.hasSupabase) return success('Action locale enregistrée.');
    try {
      final result = await Supabase.instance.client.rpc(
        'claim_daily_quest',
        params: {'p_code': code},
      );
      final map = Map<String, dynamic>.from(result as Map);
      await _markQuestCompletedLocally(code);
      return success('${map['message'] ?? 'Action enregistrée.'}');
    } catch (_) {
      await ServiceLocator().sync.enqueueAndTryFlush(
        operation: 'RPC',
        targetTable: 'claim_daily_quest',
        payload: {'p_code': code},
      );
      await _markQuestCompletedLocally(code);
      return success(
        'Action enregistrée. Sera synchronisée dès le retour de connexion.',
      );
    }
  }

  GamificationState _emptyState() =>
      const GamificationState(xp: 0, level: 1, streakDays: 0, bestStreak: 0);

  Future<GamificationState?> _fromLocalState() async {
    final rows = await _local.readList('gam:state');
    if (rows == null || rows.isEmpty) return null;
    final r = rows.first;
    return GamificationState(
      xp: r['xp'] as int? ?? 0,
      level: r['level'] as int? ?? 1,
      streakDays: r['streakDays'] as int? ?? 0,
      bestStreak: r['bestStreak'] as int? ?? 0,
    );
  }

  Future<List<DailyQuest>> _fromLocalQuests() async {
    final rows = await _local.readList('gam:quests');
    if (rows == null) return const [];
    return rows
        .map(
          (e) => DailyQuest(
            id: '${e['id']}',
            code: '${e['code'] ?? e['id']}',
            label: '${e['label']}',
            xpReward: e['xpReward'] as int? ?? 0,
            completedToday: e['completedToday'] as bool? ?? false,
          ),
        )
        .toList();
  }

  Future<void> _markQuestCompletedLocally(String code) async {
    final rows = await _local.readList('gam:quests');
    if (rows == null || rows.isEmpty) return;
    var changed = false;
    final updated = rows.map((e) {
      final row = Map<String, dynamic>.from(e);
      final rowCode = '${row['code'] ?? row['id']}';
      if (rowCode == code && row['completedToday'] != true) {
        row['completedToday'] = true;
        changed = true;
      }
      return row;
    }).toList();
    if (changed) await _local.writeList('gam:quests', updated);
  }
}
