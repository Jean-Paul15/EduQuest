import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/ruach_confetti.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_outline_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'qcm_result_stat_tile.dart';

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
          QcmResultStatTile(label: 'Score', value: '$correct / $total'),
          QcmResultStatTile(label: 'Reussite', value: '$rate%'),
          QcmResultStatTile(label: 'Fausses', value: '$wrong'),
          QcmResultStatTile(label: 'Passees', value: '$skipped'),
          QcmResultStatTile(label: 'Temps', value: '${seconds}s'),
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
}
