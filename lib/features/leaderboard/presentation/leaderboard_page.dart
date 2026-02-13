import 'package:eduquest/features/leaderboard/data/leaderboard_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});
  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final _repo = LeaderboardRepository();
  List<Map<String, dynamic>> _items = const [];
  Map<String, dynamic> _policy = const {'enabled': false};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final weekly = await _repo.weekly();
    final policy = await _repo.monthlyPolicy();
    if (!mounted) return;
    setState(() { _items = weekly; _policy = policy; });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _policy['enabled'] == true;
    final note = _policy['reward_note']?.toString();
    final s = Theme.of(context).colorScheme;
    return ListView(padding: const EdgeInsets.all(AppSpace.l), children: [
      Container(
        padding: const EdgeInsets.all(AppSpace.m),
        decoration: BoxDecoration(
          color: s.primary.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(children: [
          Icon(
            enabled ? Icons.emoji_events_rounded : Icons.toggle_off_rounded,
            color: s.primary,
          ),
          const SizedBox(width: AppSpace.m),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                enabled ? 'Recompenses mensuelles actives' : 'Recompenses mensuelles desactivees',
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                note?.isNotEmpty == true ? note! : 'Decision admin: donner ou non selon la periode.',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          )),
        ]),
      ),
      const SizedBox(height: AppSpace.l),
      ..._items.map((e) => _entryRow(e, s)),
    ]);
  }

  Widget _entryRow(Map<String, dynamic> e, ColorScheme s) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.s),
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.m),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: s.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Text(
            '${e['rank']}',
            style: TextStyle(fontWeight: FontWeight.w700, color: s.primary),
          ),
        ),
        const SizedBox(width: AppSpace.m),
        Expanded(child: Text(
          'Utilisateur ${('${e['profile_id']}').substring(0, 6)}',
          style: const TextStyle(color: AppColors.textPrimary),
        )),
        Text(
          '${e['score']} pts',
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ]),
    );
  }
}
