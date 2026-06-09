import 'dart:async';
import 'package:eduquest/features/learning/data/learning_warmup_service.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/learning/presentation/widgets/learning_page_body.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
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
    return LearningPageBody(
      pageController: _controller,
      tabsController: _tabsController,
      sections: _sections,
      currentIndex: _index,
      tabKeys: _tabKeys,
      onTabSelected: _go,
      onPageChanged: (i) {
        setState(() => _index = i);
        _syncTabVisibility(i);
        unawaited(_prime(i));
      },
    );
  }
}
