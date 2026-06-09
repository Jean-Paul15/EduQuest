import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:flutter/material.dart';

class RewardProgressCard extends StatelessWidget {
  const RewardProgressCard({super.key, required this.qualified});

  final int qualified;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final progress = (qualified / 5).clamp(0, 1).toDouble();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        border: Border.all(color: RuachColors.cream200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progression récompense',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: RuachColors.cream900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$qualified/5 filleuls qualifiés (ticket activé)',
            style: const TextStyle(color: RuachColors.cream500),
          ),
          const SizedBox(height: 8),
          RuachProgressBar(value: progress),
          const SizedBox(height: 8),
          Text(
            'À 5, bonus FULL +30 jours attribué automatiquement.',
            style: TextStyle(color: s.primary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
