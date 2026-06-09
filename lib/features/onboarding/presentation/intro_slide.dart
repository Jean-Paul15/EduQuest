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
    final tx = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 2),
        Container(
          padding: const EdgeInsets.all(RuachSpace.s4),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(RuachRadius.md),
          ),
          child: Icon(icon, color: primaryColor, size: 28),
        ),
        const SizedBox(height: RuachSpace.s6),
        Text(
          title,
          style: tx.headlineLarge,
        ),
        const SizedBox(height: RuachSpace.s3),
        Text(
          description,
          style: tx.bodyLarge?.copyWith(color: RuachColors.cream500),
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}
