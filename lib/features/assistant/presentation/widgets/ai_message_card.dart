import 'package:eduquest/features/assistant/domain/ai_chat_action.dart';
import 'package:eduquest/features/assistant/domain/ai_chat_message.dart';
import 'package:eduquest/features/assistant/presentation/widgets/ai_inline_quiz.dart';
import 'package:eduquest/features/assistant/presentation/widgets/ai_message_action_button.dart';
import 'package:eduquest/features/assistant/presentation/widgets/assistant_artifact.dart';
import 'package:eduquest/shared/ui/widgets/math_markdown.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:ruach_quiz_engine/ruach_quiz_engine.dart';

class AiMessageCard extends StatelessWidget {
  const AiMessageCard({
    super.key,
    required this.message,
    this.onQuizCompleted,
    this.onOpenAction,
  });

  final AiChatMessage message;
  final void Function(QuizResult result, QuizDefinition definition)? onQuizCompleted;
  final void Function(AiChatAction action)? onOpenAction;

  @override
  Widget build(BuildContext context) {
    final mine = message.role == 'user';
    final bg = mine ? RuachColors.gold500 : Theme.of(context).colorScheme.surfaceContainerHighest;
    final fg = mine ? RuachColors.ink50 : Theme.of(context).colorScheme.onSurface;

    final bubble = Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(RuachSpace.s3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(RuachRadius.lg)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DefaultTextStyle(
            style: TextStyle(color: fg),
            child: Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(context).textTheme.apply(bodyColor: fg, displayColor: fg),
              ),
              child: MathMarkdown(data: message.body),
            ),
          ),
          if (message.status == 'queued') ...[
            const SizedBox(height: RuachSpace.s2),
            Text('En attente de réseau', style: TextStyle(color: fg.withValues(alpha: .7), fontSize: 12)),
          ],
          if (message.hasImage) ...[
            const SizedBox(height: RuachSpace.s2),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.image_outlined, size: 14, color: fg.withValues(alpha: .7)),
              const SizedBox(width: 4),
              Text('Image jointe', style: TextStyle(color: fg.withValues(alpha: .7), fontSize: 12)),
            ]),
          ],
          if (message.quiz case final quiz?) ...[
            AiInlineQuiz(
              definitionJson: quiz.definition,
              onCompleted: (result, definition) => onQuizCompleted?.call(result, definition),
            ),
          ],
          if (message.action?.isNavigable ?? false) ...[
            const SizedBox(height: RuachSpace.s3),
            AiMessageActionButton(
              action: message.action!,
              onTap: () => onOpenAction?.call(message.action!),
            ),
          ],
        ]),
      ),
    );

    if (message.artifacts.isEmpty) return bubble;
    // Les artifacts sortent de la bulle : bloc pleine largeur sous le texte.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        bubble,
        for (final artifact in message.artifacts)
          Padding(
            padding: const EdgeInsets.only(top: RuachSpace.s3),
            child: AssistantArtifact(artifact: artifact),
          ),
      ],
    );
  }
}
