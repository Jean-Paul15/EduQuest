import 'package:eduquest/features/learning/domain/learning_subject.dart';
import 'package:eduquest/features/learning/presentation/pages/subject_tile.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:flutter/material.dart';

class SubjectSectionBody extends StatelessWidget {
  const SubjectSectionBody({
    super.key,
    required this.loading,
    required this.items,
    required this.sectionLabel,
    required this.offlineEmpty,
    required this.openingId,
    required this.onItemTap,
    required this.onRefresh,
    this.emptyTitle,
    this.emptySubtitle,
    this.isExam = false,
  });

  final bool loading;
  final List<LearningSubject> items;
  final String sectionLabel;
  final bool offlineEmpty;
  final bool isExam;
  final String? openingId;
  final void Function(LearningSubject) onItemTap;
  final Future<void> Function() onRefresh;
  final String? emptyTitle;
  final String? emptySubtitle;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(RuachSpace.s4),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
        itemBuilder: (_, __) => RuachSkeleton(
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(RuachRadius.lg),
            ),
          ),
        ),
      );
    }
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .14),
            EmptyState(
              title: emptyTitle ?? (offlineEmpty ? 'Connexion requise' : 'Aucune matière'),
              subtitle: offlineEmpty
                  ? 'Charge d’abord les matières de $sectionLabel avec Internet.'
                  : (emptySubtitle ?? 'Aucune matière disponible dans $sectionLabel.'),
              actionLabel: 'Réessayer',
              onAction: () => onRefresh(),
            ),
          ],
        ),
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
            isExam: isExam,
            onTap: () => onItemTap(e),
          );
        },
      ),
    );
  }
}
