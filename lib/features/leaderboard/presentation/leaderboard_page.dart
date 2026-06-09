import 'package:eduquest/features/leaderboard/data/leaderboard_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
    return ListView(padding: const EdgeInsets.all(RuachSpace.s4), children: [
      Container(
        padding: const EdgeInsets.all(RuachSpace.s3),
        decoration: BoxDecoration(
          color: s.primary.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(RuachRadius.lg),
        ),
        child: Row(children: [
          Icon(
            enabled ? PhosphorIconsRegular.trophy : PhosphorIconsRegular.toggleLeft,
            color: s.primary,
          ),
          const SizedBox(width: RuachSpace.s3),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                enabled ? 'Recompenses mensuelles actives' : 'Recompenses mensuelles desactivees',
                style: const TextStyle(fontWeight: FontWeight.w600, color: RuachColors.cream900),
              ),
              const SizedBox(height: 2),
              Text(
                note?.isNotEmpty == true ? note! : 'Decision admin: donner ou non selon la periode.',
                style: const TextStyle(fontSize: 13, color: RuachColors.cream500),
              ),
            ],
          )),
        ]),
      ),
      const SizedBox(height: RuachSpace.s4),
      ..._items.map((e) => _entryRow(e, s)),
    ]);
  }

  Widget _entryRow(Map<String, dynamic> e, ColorScheme s) {
    return Container(
      margin: const EdgeInsets.only(bottom: RuachSpace.s2),
      padding: const EdgeInsets.symmetric(horizontal: RuachSpace.s3, vertical: RuachSpace.s3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: RuachColors.cream200),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: s.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(RuachRadius.sm),
          ),
          child: Text(
            '${e['rank']}',
            style: TextStyle(fontWeight: FontWeight.w700, color: s.primary),
          ),
        ),
        const SizedBox(width: RuachSpace.s3),
        Expanded(child: Text(
          'Utilisateur ${('${e['profile_id']}').substring(0, 6)}',
          style: const TextStyle(color: RuachColors.cream900),
        )),
        Text(
          '${e['score']} pts',
          style: const TextStyle(fontWeight: FontWeight.w600, color: RuachColors.cream500),
        ),
      ]),
    );
  }
}
