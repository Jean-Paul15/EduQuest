import 'package:eduquest/features/learning/domain/learning_chapter.dart';
import 'package:eduquest/features/learning/presentation/pages/widgets/chapter_list_item.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:flutter/material.dart';

class ChapterListBody extends StatelessWidget {
  const ChapterListBody({
    super.key,
    required this.subjectLabel,
    required this.loading,
    required this.items,
    required this.openingId,
    required this.onChapterTap,
    required this.onRefresh,
    this.emptyTitle,
    this.emptySubtitle,
  });

  final String subjectLabel;
  final bool loading;
  final List<LearningChapter> items;
  final String? openingId;
  final ValueChanged<LearningChapter> onChapterTap;
  final Future<void> Function() onRefresh;
  final String? emptyTitle;
  final String? emptySubtitle;

  @override
  Widget build(BuildContext context) {
    final body = loading
        ? _buildLoading(context)
        : items.isEmpty
            ? EmptyState(
                title: emptyTitle ?? 'Aucun chapitre',
                subtitle: emptySubtitle ?? 'Aucun chapitre disponible.',
                actionLabel: 'Actualiser',
                onAction: () => onRefresh(),
              )
            : RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView.separated(
                  padding: const EdgeInsets.all(RuachSpace.s4),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
                  itemBuilder: (_, i) {
                    final e = items[i];
                    return ChapterListItem(
                      chapter: e,
                      displayIndex: i,
                      isOpening: openingId == e.id,
                      onTap: () => onChapterTap(e),
                    );
                  },
                ),
              );
    return Scaffold(
      appBar: RuachAppBar(title: subjectLabel, showBack: true),
      body: body,
    );
  }

  Widget _buildLoading(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.all(RuachSpace.s4),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
        itemBuilder: (_, __) => RuachSkeleton(
          child: Container(
            height: 84,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(RuachRadius.lg),
            ),
          ),
        ),
      );
}
