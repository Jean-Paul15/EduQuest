import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'intro_slide_visual.dart';

const introItems = [
  (
    'Ta réussite,\nton combat',
    'RuachEdu est fait pour ceux qui refusent la médiocrité. '
        'Des cours solides, des exercices ciblés, un suivi rigoureux. '
        'Ici, chaque effort te rapproche de l\'excellence.',
    PhosphorIconsRegular.trendUp,
    'assets/images/onboarding-home-study.jpg',
  ),
  (
    'Tout est là.\nÀ toi de jouer.',
    'Cours structurés, QCM chronométrés, corrigés '
        'détaillés, épreuves d\'examen réelles. '
        'Chaque outil est pensé pour transformer '
        'ton travail en résultats le jour J.',
    PhosphorIconsRegular.lightning,
    'assets/images/onboarding-campus.jpg',
  ),
  (
    'Même sans\nconnexion',
    'Le réseau coupe ? Ça arrive. '
        'Télécharge tes contenus et continue à avancer. '
        'Ton ambition ne s\'arrête pas '
        'là où le wifi s\'arrête.',
    PhosphorIconsRegular.wifiX,
    'assets/images/onboarding-mobile-evening.jpg',
  ),
  (
    'Un mentor,\ntoujours dispo',
    'Bloqué sur un exercice ? L\'Assistant RuachEdu t\'explique, '
        'te renvoie vers la bonne leçon et répond à tes questions '
        'à toute heure. Un prof particulier, toujours disponible '
        'dans ta poche.',
    PhosphorIconsRegular.sparkle,
    'assets/images/onboarding-ai-mentor.jpg',
  ),
];

/// Fine façade au-dessus de [IntroSlideVisual] : garde `introItems` et
/// l'usage `IntroSlide(...)` du carrousel séparés du rendu lui-même.
class IntroSlide extends StatelessWidget {
  const IntroSlide({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.imagePath,
  });

  final String title;
  final String description;
  final IconData icon;
  final String imagePath;

  @override
  Widget build(BuildContext context) => IntroSlideVisual(
        title: title,
        description: description,
        icon: icon,
        imagePath: imagePath,
      );
}
