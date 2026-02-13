class ExamEntry {
  const ExamEntry({
    required this.id,
    required this.title,
    required this.paperUrl,
    required this.correctionUrl,
    required this.semester,
  });

  final String id;
  final String title;
  final String paperUrl;
  final String? correctionUrl;
  final String? semester;
}
