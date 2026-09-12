class LearningChapter {
  const LearningChapter({
    required this.id,
    required this.title,
    required this.position,
    this.masteryPercent,
  });

  final String id;
  final String title;
  final int position;

  /// Maîtrise décroissante (mig 221), null si l'élève n'a jamais touché ce
  /// chapitre — l'UI masque alors la barre plutôt que d'afficher 0 %.
  final int? masteryPercent;
}
