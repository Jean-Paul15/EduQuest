import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, required this.name, required this.email, required this.countryCode, required this.levelCode, required this.serieCode});
  final String name;
  final String email;
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
      padding: const EdgeInsets.all(RuachSpace.s4),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(RuachRadius.lg), border: Border.all(color: cs.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 26, backgroundColor: cs.primary, child: Text(_initials(name), style: const TextStyle(color: RuachColors.white, fontWeight: FontWeight.w700, fontSize: 16))),
          const SizedBox(width: RuachSpace.s3),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(height: RuachSpace.s1),
            Text(
              email.isEmpty ? 'Profil d’apprentissage' : email,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ])),
        ]),
        const SizedBox(height: RuachSpace.s3),
        Wrap(spacing: RuachSpace.s2, runSpacing: RuachSpace.s2, children: [
          _chip(context, levelCode),
          _chip(context, 'Série $serieCode'),
          _chip(context, countryCode),
        ]),
      ]),
    );
  }

  Widget _chip(BuildContext context, String label) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(RuachRadius.full)),
      child: Text(label, style: TextStyle(fontSize: 12, color: cs.onSurface)),
    );
  }
}
