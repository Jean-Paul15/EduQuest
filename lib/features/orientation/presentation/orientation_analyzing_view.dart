import 'dart:async';

import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_loader.dart';
import 'package:eduquest/shared/ui/widgets/ruach_text_button.dart';
import 'package:flutter/material.dart';

/// Ecran d'attente pendant l'analyse serveur. Le chargeur « atome » plus les
/// etapes qui defilent donnent une vraie sensation de traitement en cours.
class OrientationAnalyzingView extends StatefulWidget {
  const OrientationAnalyzingView({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<OrientationAnalyzingView> createState() => _OrientationAnalyzingViewState();
}

class _OrientationAnalyzingViewState extends State<OrientationAnalyzingView> {
  static const _steps = [
    'Lecture de tes réponses',
    'Calcul de ton profil RIASEC',
    'Croisement avec les filières et ta série',
    'Vérification des conditions d’accès',
    'Rédaction de ton bilan personnalisé',
  ];
  int _step = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final reduce = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (!reduce) {
      _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
        if (mounted) setState(() => _step = (_step + 1) % _steps.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const RuachLoader(size: 168, period: Duration(milliseconds: 1500)),
        const SizedBox(height: RuachSpace.s4),
        Semantics(
          liveRegion: true,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: Text(
              _steps[_step],
              key: ValueKey(_step),
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: RuachSpace.s2),
        Text('Cela prend une dizaine de secondes.', style: text.bodySmall),
        const SizedBox(height: RuachSpace.s3),
        RuachTextButton(label: 'Fermer', onPressed: widget.onClose),
      ],
    );
  }
}
