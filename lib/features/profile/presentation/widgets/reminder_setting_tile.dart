import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ReminderSettingTile extends StatelessWidget {
  const ReminderSettingTile({super.key, required this.enabled, required this.hour, required this.minute, required this.onToggle, required this.onPickTime});
  final bool enabled;
  final int hour;
  final int minute;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickTime;

  String _label() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        Icon(PhosphorIconsRegular.clockCountdown, size: 18, color: s.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Rappel quotidien', style: TextStyle(fontWeight: FontWeight.w600, color: s.onSurface)),
            const SizedBox(height: 4),
            Text(enabled ? 'Heure : ${_label()}' : 'Désactivé', style: TextStyle(fontSize: 12, color: s.onSurfaceVariant)),
          ]),
        ),
        Switch(value: enabled, onChanged: onToggle),
        TextButton.icon(onPressed: enabled ? onPickTime : null, icon: const Icon(PhosphorIconsRegular.clock, size: 16), label: const Text('Heure')),
      ]),
    );
  }
}
