import 'package:eduquest/features/learning/domain/learning_subject.dart';
import 'package:eduquest/features/learning/presentation/pages/subject_tile.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class SubjectSectionBody extends StatelessWidget {
  const SubjectSectionBody({
    super.key,
    required this.loading,
    required this.items,
    required this.sectionLabel,
    required this.openingId,
    required this.onItemTap,
    required this.onRefresh,
  });

  final bool loading;
  final List<LearningSubject> items;
  final String sectionLabel;
  final String? openingId;
  final void Function(LearningSubject) onItemTap;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) {
      return EmptyState(
        title: 'Aucune matiere',
        subtitle: 'Aucune matiere disponible dans $sectionLabel.',
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(RuachSpace.s4),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
        itemBuilder: (_, i) {
          final e = items[i];
          return SubjectTile(
            subject: e,
            isOpening: openingId == e.id,
            onTap: () => onItemTap(e),
          );
        },
      ),
    );
  }
}
