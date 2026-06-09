import 'package:eduquest/features/learning/domain/exam_entry.dart';
import 'package:eduquest/features/learning/presentation/pages/widgets/exam_group_card.dart';
import 'package:eduquest/shared/security/sensitive_scope.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';

/// Body widget for ExamListPage — loading spinner, empty state, or grouped list.
class ExamListBody extends StatelessWidget {
  const ExamListBody({
    super.key,
    required this.loading,
    required this.items,
    required this.subjectLabel,
    required this.onEntryTap,
  });
  final bool loading;
  final List<ExamEntry> items;
  final String subjectLabel;
  final void Function(ExamEntry entry) onEntryTap;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (items.isEmpty) {
      return const EmptyState(title: 'Aucun document', subtitle: 'Aucun contenu disponible.');
    }
    final grouped = <String, List<ExamEntry>>{};
    for (final e in items) {
      grouped.putIfAbsent(e.semester ?? 'Session', () => []).add(e);
    }
    return SensitiveScope(
      child: Scaffold(
        appBar: RuachAppBar(title: subjectLabel),
        body: ListView(
          padding: const EdgeInsets.all(RuachSpace.s4),
          children: grouped.entries
              .map((g) => ExamGroupCard(semester: g.key, entries: g.value, onEntryTap: onEntryTap))
              .toList(),
        ),
      ),
    );
  }
}
