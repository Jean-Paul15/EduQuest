import 'dart:async';
import 'package:eduquest/features/learning/data/learning_warmup_service.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/learning/presentation/pages/subject_section_page.dart';
import 'package:eduquest/shared/security/sensitive_scope.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});
  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  late final PageController _controller;
  late final ScrollController _tabsController;
  final _warm = LearningWarmupService();
  final _sections = LearningSection.values;
  late final List<GlobalKey> _tabKeys;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _tabsController = ScrollController();
    _tabKeys = List.generate(_sections.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _syncTabVisibility(_index),
    );
    unawaited(_prime(_index));
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabsController.dispose();
    super.dispose();
  }

  Future<void> _prime(int i) async {
    await _warm.warmSection(_sections[i]);
    for (final n in [i - 1, i + 1]) {
      if (n >= 0 && n < _sections.length) {
        unawaited(_warm.warmSection(_sections[n]));
      }
    }
  }

  Future<void> _go(int i) async {
    if (_index == i) return;
    setState(() => _index = i);
    _syncTabVisibility(i);
    unawaited(_prime(i));
    await _controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  void _syncTabVisibility(int i) {
    final ctx = _tabKeys[i].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: .5,
      duration: RuachMotion.appear,
      curve: Curves.easeOutCubic,
    );
  }

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
                  controller: _tabsController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _sections.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => _Chip(
                    key: _tabKeys[i],
                    label: _sections[i].label,
                    selected: _index == i,
                    onTap: () => _go(i),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: RuachColors.cream200),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) {
                  setState(() => _index = i);
                  _syncTabVisibility(i);
                  unawaited(_prime(i));
                },
                itemCount: _sections.length,
                itemBuilder: (_, i) =>
                    SubjectSectionPage(section: _sections[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: RuachMotion.tap,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? RuachColors.gold500 : RuachColors.white,
          borderRadius: BorderRadius.circular(RuachRadius.full),
          border: Border.all(
            color: selected ? RuachColors.gold500 : RuachColors.cream200,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? RuachColors.white : RuachColors.cream500,
          ),
        ),
      ),
    );
  }
}
