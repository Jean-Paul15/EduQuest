import 'package:eduquest/features/referral/data/referral_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:flutter/material.dart';

class RewardProgressCard extends StatelessWidget {
  const RewardProgressCard({
    super.key,
    required this.invitedCount,
    required this.qualifiedCount,
    required this.items,
  });

  final int invitedCount;
  final int qualifiedCount;
  final List<ReferralProgressItem> items;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final progress = (qualifiedCount / 5).clamp(0, 1).toDouble();
    final nextMilestone = qualifiedCount >= 5 ? 'Palier principal atteint' : 'Prochain palier: ${qualifiedCount >= 1 ? '5 filleuls qualifiés' : '1 filleul qualifié'}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        border: Border.all(color: s.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progression récompense',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: s.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$qualifiedCount qualifié(s) sur $invitedCount invitation(s)',
            style: TextStyle(color: s.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          RuachProgressBar(value: progress),
          const SizedBox(height: 8),
          Text(
            nextMilestone,
            style: TextStyle(color: s.primary, fontWeight: FontWeight.w600),
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...items.take(4).map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(
                      item.qualified ? Icons.verified_rounded : Icons.timelapse_rounded,
                      size: 16,
                      color: item.qualified ? RuachColors.success600 : s.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item.name} • ${item.statusLabel}',
                        style: TextStyle(fontSize: 12, color: s.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
