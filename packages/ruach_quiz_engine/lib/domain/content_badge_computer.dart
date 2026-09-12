import 'quiz_content_block.dart';
import 'quiz_definition.dart';
import 'quiz_question.dart';

/// Calcule automatiquement les badges d'un quiz en scannant ses Content Blocks.
class ContentBadgeComputer {
  const ContentBadgeComputer();

  /// Retourne les badges triés pour un quiz.
  static List<ContentTypeBadge> compute(QuizDefinition quiz) {
    final badges = <ContentTypeBadge>{};

    // Scan des questions (pool en mode adaptatif, liste fixe sinon).
    for (final q in quiz.effectiveQuestions) {
      for (final b in q.statement) {
        _addFromBlock(b, badges);
      }
      if (q.mediaAbove != null) {
        _addFromBlock(q.mediaAbove!, badges);
      }
      if (_isInteractive(q.type)) {
        badges.add(ContentTypeBadge.interactive);
      }
    }

    // Scan des groupes
    for (final g in quiz.groups) {
      for (final b in g.sharedContext) {
        _addFromBlock(b, badges);
      }
      if (g.sharedMedia != null) {
        _addFromBlock(g.sharedMedia!, badges);
      }
    }

    return badges.toList()..sort((a, b) => a.index.compareTo(b.index));
  }

  static void _addFromBlock(ContentBlock block, Set<ContentTypeBadge> badges) {
    final badge = switch (block) {
      LatexBlock() => ContentTypeBadge.latex,
      ImageBlock() => ContentTypeBadge.image,
      CodeBlock() => ContentTypeBadge.code,
      AudioBlock() => ContentTypeBadge.audio,
      CalloutBlock() => null,
      TextBlock() => null,
      TableBlock() => null,
    };
    if (badge != null) badges.add(badge);

    // Récursion dans les callouts et tableaux
    if (block is CalloutBlock) {
      for (final child in block.content) {
        _addFromBlock(child, badges);
      }
    }
    if (block is TableBlock) {
      for (final h in block.headers) {
        _addFromBlock(h, badges);
      }
      for (final row in block.rows) {
        for (final cell in row) {
          _addFromBlock(cell, badges);
        }
      }
    }
  }

  static bool _isInteractive(QuestionType t) => switch (t) {
    QuestionType.fillBlank || QuestionType.fillBlanks ||
    QuestionType.cloze || QuestionType.matching => true,
    _ => false,
  };
}
