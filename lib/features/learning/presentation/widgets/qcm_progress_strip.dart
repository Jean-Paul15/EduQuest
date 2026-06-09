import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class QcmProgressStrip extends StatelessWidget {
  const QcmProgressStrip({
    super.key,
    required this.ratio,
    required this.leftSeconds,
  });

  final double ratio;
  final int leftSeconds;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 4,
            backgroundColor: RuachColors.cream200,
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Icon(PhosphorIconsRegular.timer, size: 16, color: RuachColors.gold600),
          const SizedBox(width: 4),
          Text(
            '${leftSeconds}s',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: RuachColors.cream900,
            ),
          ),
        ]),
      ],
    );
  }
}
