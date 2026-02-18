import 'package:eduquest/features/legal/data/legal_repository.dart';
import 'package:eduquest/features/legal/presentation/legal_document_page.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
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
  static const _items = [
    (
      'Ta réussite,\nton combat',
      'EduQuest est fait pour ceux qui refusent la médiocrité. '
          'Des cours solides, des exercices ciblés, un suivi rigoureux '
          '— ici, chaque effort te rapproche de l\'excellence.',
      Icons.trending_up_rounded,
    ),
    (
      'Tout est là.\nÀ toi de jouer.',
      'Cours structurés, QCM chronométrés, corrigés '
          'détaillés, épreuves d\'examen réelles. '
          'Chaque outil est pensé pour transformer '
          'ton travail en résultats le jour J.',
      Icons.bolt_rounded,
    ),
    (
      'Même sans\nconnexion',
      'Le réseau coupe ? Ça arrive. '
          'Télécharge tes contenus et continue à avancer. '
          'Ton ambition ne s\'arrête pas '
          'là où le wifi s\'arrête.',
      Icons.wifi_off_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _preloadLegal();
  }

  Future<void> _preloadLegal() async {
    setState(() => _legalLoading = true);
    try {
      await Future.wait([
        _legal.load('terms'),
        _legal.load('privacy'),
      ]).timeout(const Duration(seconds: 6));
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Expanded(
                child: PageView.builder(
                  controller: _ctrl,
                  itemCount: _items.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) {
                    final item = _items[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(flex: 2),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: s.primary.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(AppRadius.s),
                          ),
                          child: Icon(item.$3, color: s.primary, size: 28),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          item.$1,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.$2,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const Spacer(flex: 3),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: List.generate(
                  _items.length,
                  (i) => AnimatedContainer(
                    duration: AppMotion.normal,
                    width: i == _index ? 24 : 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: i == _index
                          ? s.primary
                          : AppColors.textTertiary.withValues(alpha: .3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'En continuant, tu acceptes nos conditions.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _legalLoading
                        ? null
                        : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LegalDocumentPage(docType: 'terms'),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Conditions'),
                  ),
                  TextButton(
                    onPressed: _legalLoading
                        ? null
                        : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LegalDocumentPage(docType: 'privacy'),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Confidentialite'),
                  ),
                  if (_legalLoading)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting
                      ? null
                      : () async {
                          final last = _items.length - 1;
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
                  child: Text(
                    _index < _items.length - 1
                        ? 'Poursuivre'
                        : (_submitting ? 'Chargement...' : 'Commencer'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
