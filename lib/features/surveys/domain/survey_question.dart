class SurveyQuestion {
  const SurveyQuestion({
    required this.id,
    required this.prompt,
    required this.type,
    required this.options,
  });

  final String id;
  final String prompt;
  final String type;
  final List<String> options;
}
