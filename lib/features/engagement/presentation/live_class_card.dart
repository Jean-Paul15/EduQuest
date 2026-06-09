import 'package:eduquest/features/engagement/domain/live_class_item.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LiveClassCard extends StatelessWidget {
  const LiveClassCard({super.key, required this.item, required this.onJoin});
  final LiveClassItem item;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: RuachColors.cream200),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(RuachSpace.s2),
            decoration: BoxDecoration(
              color: s.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(RuachRadius.sm),
            ),
            child: Icon(PhosphorIconsRegular.videoCamera, size: 20, color: s.primary),
          ),
          const SizedBox(width: RuachSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: RuachColors.cream900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.startsAt.toLocal()} — ${item.endsAt.toLocal()}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: RuachColors.cream700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: RuachSpace.s2),
          RuachButton(label: 'Rejoindre', onPressed: onJoin),
        ],
      ),
    );
  }
}
