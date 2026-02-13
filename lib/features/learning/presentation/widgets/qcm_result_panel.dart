import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Resultats',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
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
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Recommencer'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Terminer'),
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.canvasLight,
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
