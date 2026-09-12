import 'package:eduquest/features/learning/domain/exam_entry.dart';
import 'package:eduquest/features/learning/presentation/pages/widgets/exam_group_card.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:flutter/material.dart';

/// Body widget for ExamListPage — loading spinner, empty state, or grouped list.
class ExamListBody extends StatelessWidget {
  const ExamListBody({
    super.key,
    required this.loading,
    required this.refreshing,
    required this.items,
    required this.subjectLabel,
    required this.onEntryTap,
    required this.onRefresh,
    this.emptyTitle,
    this.emptySubtitle,
  });
  final bool loading;
  final bool refreshing;
  final List<ExamEntry> items;
  final String subjectLabel;
  final void Function(ExamEntry entry) onEntryTap;
  final Future<void> Function() onRefresh;
  final String? emptyTitle;
  final String? emptySubtitle;

  @override
  Widget build(BuildContext context) {
    if (loading) return _loadingScaffold(context);
    if (items.isEmpty) {
      return Scaffold(
        appBar: RuachAppBar(title: subjectLabel, showBack: true),
        body: EmptyState(
          title: emptyTitle ?? 'Aucun document',
          subtitle: emptySubtitle ?? 'Aucun contenu disponible.',
          actionLabel: 'Actualiser',
          onAction: () => onRefresh(),
        ),
      );
    }
    final grouped = <String, List<ExamEntry>>{};
    for (final e in items) {
      grouped.putIfAbsent(e.semester ?? 'Session', () => []).add(e);
    }
    return Scaffold(
      appBar: RuachAppBar(title: subjectLabel, showBack: true),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(RuachSpace.s4),
          children: [
            if (refreshing)
              const Padding(
                padding: EdgeInsets.only(bottom: RuachSpace.s2),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            ...grouped.entries.map(
              (g) => ExamGroupCard(
                semester: g.key,
                entries: g.value,
                onEntryTap: onEntryTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingScaffold(BuildContext context) => Scaffold(
    appBar: RuachAppBar(title: subjectLabel, showBack: true),
    body: ListView.separated(
      padding: const EdgeInsets.all(RuachSpace.s4),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
      itemBuilder: (_, __) => RuachSkeleton(
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(RuachRadius.lg),
          ),
        ),
      ),
    ),
  );
}
