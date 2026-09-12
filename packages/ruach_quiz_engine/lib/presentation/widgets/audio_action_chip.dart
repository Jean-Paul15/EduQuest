import 'package:flutter/material.dart';
import '../constants.dart';

class AudioActionChip extends StatelessWidget {
  const AudioActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(999),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceBase,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: surfaceStroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cream900),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: cream900,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
