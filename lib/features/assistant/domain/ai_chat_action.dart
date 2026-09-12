/// Action de navigation in-app attachée à une réponse de l'assistant
/// (événement SSE `done`, champ `action`). L'assistant ne renvoie jamais
/// d'URL de PDF : pour consulter un sujet complet, le client affiche un
/// bouton natif qui pousse l'écran concerné.
///
/// Deux types : `open_exam_list` — ouvre la liste des épreuves/examens d'une
/// matière, dans la catégorie déjà résolue côté Edge Function (`national` /
/// `epreuve` / `mock`) — et `open_chapter` — ouvre directement un chapitre
/// (méprise la plus fréquente d'un quiz raté, cf `student_misconceptions`).
class AiChatAction {
  const AiChatAction({
    required this.type,
    required this.label,
    this.subjectId,
    this.subjectLabel,
    this.category,
    this.chapterId,
    this.chapterTitle,
  });

  final String type;
  final String label;
  final String? subjectId;
  final String? subjectLabel;
  final String? category;
  final String? chapterId;
  final String? chapterTitle;

  bool get isOpenExamList =>
      type == 'open_exam_list' &&
      (subjectId?.isNotEmpty ?? false) &&
      (category?.isNotEmpty ?? false);

  bool get isOpenChapter =>
      type == 'open_chapter' && (chapterId?.isNotEmpty ?? false);

  /// Vrai pour tout type reconnu et complet — condition d'affichage du bouton.
  bool get isNavigable => isOpenExamList || isOpenChapter;

  static AiChatAction? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final type = '${map['type'] ?? ''}'.trim();
    final label = '${map['label'] ?? ''}'.trim();
    if (type.isEmpty || label.isEmpty) return null;
    return AiChatAction(
      type: type,
      label: label,
      subjectId: (map['subject_id'] as Object?)?.toString().trim(),
      subjectLabel: (map['subject_label'] as Object?)?.toString().trim(),
      category: (map['category'] as Object?)?.toString().trim(),
      chapterId: (map['chapter_id'] as Object?)?.toString().trim(),
      chapterTitle: (map['chapter_title'] as Object?)?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'label': label,
    if (subjectId != null) 'subject_id': subjectId,
    if (subjectLabel != null) 'subject_label': subjectLabel,
    if (category != null) 'category': category,
    if (chapterId != null) 'chapter_id': chapterId,
    if (chapterTitle != null) 'chapter_title': chapterTitle,
  };
}
