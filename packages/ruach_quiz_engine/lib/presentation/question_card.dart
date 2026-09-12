import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../domain/quiz_question.dart';
import '../domain/quiz_answer.dart';
import 'constants.dart';
import 'renderers/question_renderer.dart';
import 'widgets/content_block_renderer.dart';
import 'widgets/quiz_surface_panel.dart';
import 'tokens.dart';

/// Dispatches to the correct renderer based on question type.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    this.locked = false,
    this.editable = false,
    this.selectedAnswer,
    required this.onAnswer,
    this.cacheManager,
    this.onImageLoadFailed,
    this.requireValidation = false,
    this.onDraft,
  });

  final QuizQuestion question;
  final bool locked;
  final bool editable;
  final QuizAnswer? selectedAnswer;
  final ValueChanged<QuizAnswer> onAnswer;
  final CacheManager? cacheManager;
  final ValueChanged<String>? onImageLoadFailed;

  /// Voir [QuestionRenderer.requireValidation].
  final bool requireValidation;

  /// Voir [QuestionRenderer.onDraft].
  final ValueChanged<QuizAnswer?>? onDraft;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: QuizSurfacePanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContext(context),
            _buildMediaAbove(),
            if (question.statement.isNotEmpty)
              ContentBlockRenderer(
                blocks: question.statement,
                cacheManager: cacheManager,
                onImageLoadFailed: onImageLoadFailed,
              )
            else if (question.prompt.isNotEmpty)
              Text(
                question.prompt,
                style: TextStyle(
                  color: cream900,
                  fontSize: 16,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (question.statement.isNotEmpty || question.prompt.isNotEmpty)
              const SizedBox(height: 14),
            QuestionRenderer.forType(
              question.type,
              question: question,
              onAnswer: onAnswer,
              locked: locked,
              editable: editable,
              existingAnswer: selectedAnswer,
              requireValidation: requireValidation,
              onDraft: onDraft,
            ),
            const SizedBox(height: 14),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildContext(BuildContext context) {
    final ctx = question.context;
    if (ctx == null || ctx.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ink800,
        borderRadius: BorderRadius.circular(QuizRadius.sm),
        border: Border.all(color: cream200),
      ),
      child: Text(ctx, style: TextStyle(color: cream700, fontSize: 14)),
    );
  }

  Widget _buildMediaAbove() {
    final m = question.mediaAbove;
    if (m == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ContentBlockRenderer(
        blocks: [m],
        cacheManager: cacheManager,
        onImageLoadFailed: onImageLoadFailed,
      ),
    );
  }

  Widget _buildFooter() {
    final meta = question.points > 0
        ? '${question.points} point${question.points > 1 ? 's' : ''}'
        : 'Orientation';
    return Row(
      children: [
        Text(
          meta,
          style: TextStyle(
            color: gold500,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: goldGlow,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: gold500.withValues(alpha: .35)),
          ),
          child: Text(
            questionTypeLabel(question.type),
            style: TextStyle(color: gold500, fontSize: 10.5),
          ),
        ),
      ],
    );
  }
}
