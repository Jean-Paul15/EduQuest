import 'package:eduquest/features/learning/domain/learning_chapter.dart';
import 'package:eduquest/features/learning/presentation/widgets/learning_nav_card.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ChapterListItem extends StatelessWidget {
  const ChapterListItem({
    super.key,
    required this.chapter,
    required this.displayIndex,
    required this.isOpening,
    required this.onTap,
  });

  final LearningChapter chapter;
  final int displayIndex;
  final bool isOpening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mastery = chapter.masteryPercent;
    return LearningNavCard(
      title: chapter.title,
      subtitle: 'Chapitre ${displayIndex + 1}',
      icon: PhosphorIconsRegular.bookBookmark,
      loading: isOpening,
      onTap: onTap,
      // Uniquement si l'élève a déjà touché ce chapitre : 0 % réel affiché,
      // jamais un 0 % par défaut pour du contenu jamais ouvert (voir
      // list_chapters_with_mastery, mig 221).
      footer: mastery == null ? null : _MasteryFooter(percent: mastery),
    );
  }
}

class _MasteryFooter extends StatelessWidget {
  const _MasteryFooter({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Maîtrise',
              style: TextStyle(fontSize: 11, color: onSurfaceVariant),
            ),
            Text(
              '$percent %',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: RuachColors.gold600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        RuachProgressBar(value: percent / 100),
      ],
    );
  }
}
