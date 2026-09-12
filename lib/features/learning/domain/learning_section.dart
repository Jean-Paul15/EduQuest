enum LearningSection {
  courses('Cours'),
  // Juste après Cours (voir LearningPageBody) : recommandations issues de
  // l'analyse IA (méprises + maîtrise + révisions dues), jamais de contenu
  // générique — assez visible pour que l'élève la voie sans chercher.
  forYou('Pour toi'),
  exams('Examens'),
  epreuves('Épreuves'),
  mockExams('Examens blancs'),
  videos('Vidéos'),
  youtube('YouTube');

  const LearningSection(this.label);
  final String label;
}
