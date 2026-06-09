import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/learning/presentation/pages/subject_section_page.dart';
import 'package:eduquest/features/learning/presentation/widgets/learning_tab_chip.dart';
import 'package:eduquest/shared/security/sensitive_scope.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
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
    return SensitiveScope(
      child: Scaffold(
        backgroundColor: RuachColors.cream50,
        appBar: const RuachAppBar(title: 'Apprendre'),
        body: Column(
          children: [
            Container(
              color: RuachColors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                height: 36,
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
            ),
            const Divider(height: 1, color: RuachColors.cream200),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: onPageChanged,
                itemCount: sections.length,
                itemBuilder: (_, i) => SubjectSectionPage(section: sections[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
