import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = PhosphorIconsRegular.tray,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: scheme.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(PhosphorIconsRegular.arrowsClockwise, size: 18),
              label: Text(actionLabel!),
            ),
          ],
        ]),
      ),
    );
  }
}
