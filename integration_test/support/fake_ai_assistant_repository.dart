import 'package:eduquest/features/assistant/data/ai_assistant_repository.dart';
import 'package:eduquest/features/assistant/domain/ai_chat_artifact.dart';
import 'package:eduquest/features/assistant/domain/ai_chat_message.dart';
import 'package:eduquest/features/assistant/domain/ai_composer_attachment.dart';

class FakeAiAssistantRepository extends AiAssistantRepository {
  FakeAiAssistantRepository({
    this.throwOnAsk = false,
    this.initialMessages = const [],
    this.delay = Duration.zero,
    this.streamChunks,
  });

  final bool throwOnAsk;
  final List<AiChatMessage> initialMessages;
  final Duration delay;
  /// Si renseigné, simule un flux SSE en appelant `onDelta` avec chacun de ces fragments
  /// (séparés par [delay]) avant de résoudre — pour tester l'affichage progressif.
  final List<String>? streamChunks;
  List<AiChatMessage> persisted = const [];
  AiComposerAttachment? lastImage;

  @override
  Future<(String?, List<AiChatMessage>)> load() async => ('thread-1', initialMessages);

  @override
  Future<AiAssistantReply> ask(
    String prompt, {
    String? threadId,
    String? subjectId,
    String? chapterId,
    AiComposerAttachment? image,
    Map<String, dynamic>? quizResult,
    String? mode,
    void Function(String delta)? onDelta,
    void Function(String tool, String status)? onTool,
    void Function(AiChatArtifact artifact)? onArtifact,
  }) async {
    lastImage = image;
    final chunks = streamChunks;
    if (chunks != null) {
      final body = StringBuffer();
      for (final chunk in chunks) {
        if (delay > Duration.zero) await Future.delayed(delay);
        body.write(chunk);
        onDelta?.call(chunk);
      }
      if (throwOnAsk) throw StateError('assistant-down');
      return AiAssistantReply(
        threadId ?? 'thread-1',
        AiChatMessage(role: 'assistant', body: body.toString(), createdAt: DateTime(2026)),
        false,
        null,
        const [],
      );
    }
    if (delay > Duration.zero) await Future.delayed(delay);
    if (throwOnAsk) throw StateError('assistant-down');
    return AiAssistantReply(
      threadId ?? 'thread-1',
      AiChatMessage(
        role: 'assistant',
        body: 'Réponse de test pour: $prompt',
        createdAt: DateTime(2026),
      ),
      false,
      null,
      const [],
    );
  }

  @override
  Future<void> persist(String? threadId, List<AiChatMessage> messages) async {
    persisted = messages;
  }
}
