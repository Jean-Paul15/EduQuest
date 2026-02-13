import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class ReminderSettingTile extends StatelessWidget {
  const ReminderSettingTile({
    super.key,
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.onToggle,
    required this.onPickTime,
  });

  final bool enabled;
  final int hour;
  final int minute;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickTime;

  String _label() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.m,
        vertical: AppSpace.s,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rappel quotidien',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              enabled ? 'Heure: ${_label()}' : 'Desactive',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        )),
        Switch(value: enabled, onChanged: onToggle),
        IconButton(
          onPressed: enabled ? onPickTime : null,
          icon: const Icon(Icons.schedule_rounded),
          tooltip: "Choisir l'heure",
        ),
      ]),
    );
  }
}
