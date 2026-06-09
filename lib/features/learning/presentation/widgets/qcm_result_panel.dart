import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/ruach_animations.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_outline_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class QcmResultPanel extends StatelessWidget {
  const QcmResultPanel({
    super.key,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.seconds,
    required this.onRetry,
  });

  final int total;
  final int correct;
  final int wrong;
  final int skipped;
  final int seconds;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final rate = total == 0 ? 0 : ((correct / total) * 100).round();
    final success = rate >= 50;
    return ConfettiOverlay(
      active: success,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Resultats',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: RuachColors.cream900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          _stat('Score', '$correct / $total'),
          _stat('Reussite', '$rate%'),
          _stat('Fausses', '$wrong'),
          _stat('Passees', '$skipped'),
          _stat('Temps', '${seconds}s'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: RuachButton(
              label: 'Recommencer',
              onPressed: onRetry,
              icon: PhosphorIconsRegular.arrowsClockwise,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: RuachOutlineButton(
              label: 'Terminer',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: RuachColors.cream50,
        borderRadius: BorderRadius.circular(RuachRadius.md),
        border: Border.all(color: RuachColors.cream200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: RuachColors.cream500,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: RuachColors.cream900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
