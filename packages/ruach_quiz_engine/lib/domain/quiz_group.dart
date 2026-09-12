import 'quiz_content_block.dart';

/// Groupe de questions liées par un contexte ou média commun.
enum GroupLayout { sequential, allVisible }

class QuestionGroup {
  const QuestionGroup({
    required this.id,
    this.title,
    this.sharedContext = const [],
    this.sharedMedia,
    this.layout = GroupLayout.sequential,
  });

  final String id;
  final String? title;
  final List<ContentBlock> sharedContext;
  final ContentBlock? sharedMedia;
  final GroupLayout layout;
}
