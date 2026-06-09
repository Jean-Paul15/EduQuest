import 'package:eduquest/features/legal/data/legal_repository.dart';
import 'package:eduquest/features/onboarding/presentation/intro_bottom_section.dart';
import 'package:eduquest/features/onboarding/presentation/intro_page_indicator.dart';
import 'package:eduquest/features/onboarding/presentation/intro_slide.dart';
import 'package:flutter/material.dart';

class OnboardingIntroPage extends StatefulWidget {
  const OnboardingIntroPage({super.key, required this.onContinue});
  final Future<void> Function() onContinue;
  @override
  State<OnboardingIntroPage> createState() => _OnboardingIntroPageState();
}

class _OnboardingIntroPageState extends State<OnboardingIntroPage> {
  final _ctrl = PageController();
  final _legal = LegalRepository();
  int _index = 0;
  bool _submitting = false;
  bool _legalLoading = true;

  @override
  void initState() {
    super.initState();
    _preloadLegal();
  }

  Future<void> _preloadLegal() async {
    try {
      await Future.wait([_legal.load('terms'), _legal.load('privacy')])
          .timeout(const Duration(seconds: 6));
    } catch (_) {}
    if (!mounted) return;
    setState(() => _legalLoading = false);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
              const SizedBox(height: 24),
              Expanded(
                child: PageView.builder(
                  controller: _ctrl,
                  itemCount: introItems.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) {
                    final item = introItems[i];
                    return IntroSlide(
                      title: item.$1,
                      description: item.$2,
                      icon: item.$3,
                      primaryColor: s.primary,
                    );
                  },
                ),
              ),
              IntroPageIndicator(
                itemCount: introItems.length,
                currentIndex: _index,
                primaryColor: s.primary,
              ),
              const SizedBox(height: 24),
              IntroBottomSection(
                legalLoading: _legalLoading,
                isSubmitting: _submitting,
                hasNext: _index < introItems.length - 1,
                onContinuePressed: () async {
                  final last = introItems.length - 1;
                  if (_index < last) {
                    await _ctrl.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                    );
                    return;
                  }
                  setState(() => _submitting = true);
                  try {
                    await widget.onContinue();
                  } finally {
                    if (mounted) setState(() => _submitting = false);
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
