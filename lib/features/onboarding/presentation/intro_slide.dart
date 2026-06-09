import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

const introItems = [
  (
    'Ta réussite,\nton combat',
    'RuachEdu est fait pour ceux qui refusent la médiocrité. '
        'Des cours solides, des exercices ciblés, un suivi rigoureux '
        '— ici, chaque effort te rapproche de l\'excellence.',
    PhosphorIconsRegular.trendUp,
  ),
  (
    'Tout est là.\nÀ toi de jouer.',
    'Cours structurés, QCM chronométrés, corrigés '
        'détaillés, épreuves d\'examen réelles. '
        'Chaque outil est pensé pour transformer '
        'ton travail en résultats le jour J.',
    PhosphorIconsRegular.lightning,
  ),
  (
    'Même sans\nconnexion',
    'Le réseau coupe ? Ça arrive. '
        'Télécharge tes contenus et continue à avancer. '
        'Ton ambition ne s\'arrête pas '
        'là où le wifi s\'arrête.',
    PhosphorIconsRegular.wifiX,
  ),
];

class IntroSlide extends StatelessWidget {
  const IntroSlide({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 2),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(RuachRadius.md),
          ),
          child: Icon(icon, color: primaryColor, size: 28),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.5,
            color: RuachColors.cream900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            color: RuachColors.cream500,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}
