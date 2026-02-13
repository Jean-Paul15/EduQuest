enum LearningSection {
  courses('Cours'),
  exams('Examens'),
  epreuves('Épreuves'),
  mockExams('Examens blancs'),
  videos('Vidéos'),
  youtube('YouTube');

  const LearningSection(this.label);
  final String label;
}
