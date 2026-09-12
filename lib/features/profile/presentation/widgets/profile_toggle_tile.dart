import 'package:flutter/material.dart';

class ProfileToggleTile extends StatelessWidget {
  const ProfileToggleTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ],
          ]),
        ),
        Switch(value: value, onChanged: onChanged),
      ]),
    );
  }
}
