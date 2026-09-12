class AiQuizPayload {
  const AiQuizPayload({
    required this.source,
    required this.definition,
    this.quizId,
    this.subjectId,
    this.chapterId,
  });

  final String source;
  final Map<String, dynamic> definition;
  final String? quizId;
  final String? subjectId;
  final String? chapterId;

  factory AiQuizPayload.fromJson(Map<String, dynamic> json) => AiQuizPayload(
    source: '${json['source'] ?? 'generated'}',
    definition: Map<String, dynamic>.from(json['definition'] as Map? ?? const {}),
    quizId: json['quizId'] as String?,
    subjectId: json['subjectId'] as String?,
    chapterId: json['chapterId'] as String?,
  );
}
