import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MyCodeCard extends StatelessWidget {
  const MyCodeCard({
    super.key,
    required this.myCode,
    required this.count,
    required this.onRefresh,
    required this.onCopyCode,
  });

  final String myCode;
  final int count;
  final VoidCallback onRefresh;
  final VoidCallback onCopyCode;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
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
          Row(
            children: [
              Text(
                'Mon code',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: s.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: s.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(RuachRadius.sm),
                ),
                child: Text(
                  '$count invités',
                  style: TextStyle(
                    color: s.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            myCode.isEmpty ? 'Indisponible' : myCode,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: myCode.isEmpty
                  ? s.onSurfaceVariant
                  : s.onSurface,
              letterSpacing: myCode.isEmpty ? 0 : 1.5,
            ),
          ),
          if (myCode.isEmpty) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(PhosphorIconsRegular.arrowsClockwise, size: 16),
              label: const Text('Actualiser'),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: onCopyCode,
                  icon: const Icon(PhosphorIconsRegular.copy, size: 16),
                  label: const Text('Copier le code'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
