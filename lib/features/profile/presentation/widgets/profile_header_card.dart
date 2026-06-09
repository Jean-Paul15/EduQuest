import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.countryCode,
    required this.levelCode,
    required this.serieCode,
  });

  final String name;
  final String countryCode;
  final String levelCode;
  final String serieCode;

  static String _initials(String s) {
    final p = s.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (p.isEmpty) return 'E';
    return p.length == 1 ? p[0][0].toUpperCase() : '${p[0][0]}${p.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        border: Border.all(color: RuachColors.cream200),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: cs.primary,
          child: Text(_initials(name),
              style: const TextStyle(color: RuachColors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: RuachColors.cream900)),
              const SizedBox(height: 2),
              Text('$levelCode • Série $serieCode • $countryCode',
                  style: const TextStyle(fontSize: 13, color: RuachColors.cream500)),
            ],
          ),
        ),
      ]),
    );
  }
}
