import 'package:eduquest/features/learning/domain/learning_chapter.dart';
import 'package:eduquest/features/learning/presentation/pages/widgets/chapter_list_item.dart';
import 'package:eduquest/shared/security/sensitive_scope.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';

class ChapterListBody extends StatelessWidget {
  const ChapterListBody({
    super.key,
    required this.subjectLabel,
    required this.items,
    required this.openingId,
    required this.onChapterTap,
  });

  final String subjectLabel;
  final List<LearningChapter> items;
  final String? openingId;
  final ValueChanged<LearningChapter> onChapterTap;

  @override
  Widget build(BuildContext context) {
    return SensitiveScope(
      child: Scaffold(
        appBar: RuachAppBar(title: subjectLabel),
        body: ListView.separated(
          padding: const EdgeInsets.all(RuachSpace.s4),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
          itemBuilder: (_, i) {
            final e = items[i];
            return ChapterListItem(
              chapter: e,
              isOpening: openingId == e.id,
              onTap: () => onChapterTap(e),
            );
          },
        ),
      ),
    );
  }
}
