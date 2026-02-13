class QcmQuestion {
  const QcmQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.answer,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final String answer;
}
