import 'package:eduquest/features/leaderboard/data/leaderboard_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with RealtimeRefreshable<LeaderboardPage> {
  @override
  List<String> get realtimeNamespaces => const ['leaderboard'];

  @override
  Future<void> reloadFromRealtime() => _load();

  final _repo = LeaderboardRepository();
  List<Map<String, dynamic>> _items = const [];
  Map<String, dynamic> _policy = const {'enabled': false};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final weekly = await _repo.weekly();
    final policy = await _repo.monthlyPolicy();
    if (!mounted) return;
    setState(() {
      _items = weekly;
      _policy = policy;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      final body = ListView.separated(
        padding: const EdgeInsets.all(RuachSpace.s4),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
        itemBuilder: (_, __) => const _LeaderboardSkeleton(),
      );
      if (widget.embedded) return body;
      return Scaffold(
        appBar: const RuachAppBar(title: 'Classement', showBack: true),
        body: body,
      );
    }
    final enabled = _policy['enabled'] == true;
    final note = _policy['reward_note']?.toString();
    final s = Theme.of(context).colorScheme;
    final body = _items.isEmpty
        ? EmptyState(
            title: 'Classement en attente',
            subtitle: 'Les premiers scores apparaîtront ici.',
            icon: PhosphorIconsRegular.trophy,
            actionLabel: 'Actualiser',
            onAction: _load,
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(RuachSpace.s4),
              children: [
                Container(
                  padding: const EdgeInsets.all(RuachSpace.s3),
                  decoration: BoxDecoration(
                    color: s.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(RuachRadius.lg),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        enabled
                            ? PhosphorIconsRegular.trophy
                            : PhosphorIconsRegular.toggleLeft,
                        color: s.primary,
                      ),
                      const SizedBox(width: RuachSpace.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              enabled
                                  ? 'Récompenses mensuelles actives'
                                  : 'Récompenses mensuelles désactivées',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: s.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              note?.isNotEmpty == true
                                  ? note!
                                  : 'Décision admin : donner ou non selon la période.',
                              style: TextStyle(
                                fontSize: 13,
                                color: s.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: RuachSpace.s4),
                ..._items.map((e) => _entryRow(e, s)),
              ],
            ),
          );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: const RuachAppBar(title: 'Classement', showBack: true),
      body: body,
    );
  }

  Widget _entryRow(Map<String, dynamic> e, ColorScheme s) {
    return Container(
      margin: const EdgeInsets.only(bottom: RuachSpace.s2),
      padding: const EdgeInsets.symmetric(
        horizontal: RuachSpace.s3,
        vertical: RuachSpace.s3,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: s.outlineVariant),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
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
          Expanded(
            child: Text(
              'Utilisateur ${('${e['profile_id']}').substring(0, 6)}',
              style: TextStyle(color: s.onSurface),
            ),
          ),
          Text(
            '${e['score']} pts',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: s.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardSkeleton extends StatelessWidget {
  const _LeaderboardSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RuachSkeleton(
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RuachRadius.lg),
          border: Border.all(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}
