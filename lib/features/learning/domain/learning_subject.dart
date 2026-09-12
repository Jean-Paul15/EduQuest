class LearningSubject {
  const LearningSubject({
    required this.id,
    required this.code,
    required this.label,
    this.availableChapterCount = 0,
  });

  final String id;
  final String code;
  final String label;
  final int availableChapterCount;
}
