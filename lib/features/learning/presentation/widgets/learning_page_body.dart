import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/learning/presentation/pages/review_section_page.dart';
import 'package:eduquest/features/learning/presentation/pages/subject_section_page.dart';
import 'package:eduquest/features/learning/presentation/widgets/learning_tab_chip.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';

class LearningPageBody extends StatelessWidget {
  const LearningPageBody({
    super.key,
    required this.pageController,
    required this.tabsController,
    required this.sections,
    required this.currentIndex,
    required this.tabKeys,
    required this.onTabSelected,
    required this.onPageChanged,
  });

  final PageController pageController;
  final ScrollController tabsController;
  final List<LearningSection> sections;
  final int currentIndex;
  final List<GlobalKey> tabKeys;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const RuachAppBar(title: 'Apprendre'),
      body: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choisis un espace d’apprentissage',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cours, épreuves, vidéos et révisions dans un seul flux.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      controller: tabsController,
                      scrollDirection: Axis.horizontal,
                      itemCount: sections.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => LearningTabChip(
                        key: tabKeys[i],
                        label: sections[i].label,
                        selected: currentIndex == i,
                        onTap: () => onTabSelected(i),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: onPageChanged,
                itemCount: sections.length,
                itemBuilder: (_, i) => sections[i] == LearningSection.forYou
                    ? const ReviewSectionPage()
                    : SubjectSectionPage(section: sections[i]),
              ),
            ),
          ],
        ),
      );
  }
}
