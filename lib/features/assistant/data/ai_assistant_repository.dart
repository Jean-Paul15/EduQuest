import 'dart:convert';

import 'package:eduquest/features/assistant/domain/ai_chat_action.dart';
import 'package:eduquest/features/assistant/domain/ai_chat_artifact.dart';
import 'package:eduquest/features/assistant/domain/ai_chat_message.dart';
import 'package:eduquest/features/assistant/domain/ai_composer_attachment.dart';
import 'package:eduquest/features/assistant/domain/ai_quiz_payload.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class AiAssistantReply {
  const AiAssistantReply(
    this.threadId,
    this.message,
    this.cached,
    this.quiz,
    this.artifacts,
  );
  final String threadId;
  final AiChatMessage message;
  final bool cached;
  final AiQuizPayload? quiz;
  final List<AiChatArtifact> artifacts;
}

class AiAssistantRepository {
  final _local = LocalJsonCache();
  final _sb = Supabase.instance.client;
  static const _threadKey = 'ai:thread';
  static const _messagesKey = 'ai:messages';
  // Au-delà de ce délai d'inactivité, on ne reprend plus le thread précédent : la conversation
  // repart à neuf (rien n'est supprimé, le thread abandonné reste distillable plus tard).
  static const _sessionFreshness = Duration(hours: 8);

  Future<(String?, List<AiChatMessage>)> load() async {
    final local = await _loadLocal();
    if (!Env.hasSupabase || _sb.auth.currentUser == null) return local;
    try {
      final thread = await _sb.from('ai_chat_threads')
          .select('id,last_message_at').order('last_message_at', ascending: false).limit(1).maybeSingle();
      final id = thread?['id']?.toString();
      if (id == null) return local;
      final lastMessageAt = DateTime.tryParse('${thread?['last_message_at'] ?? ''}');
      if (lastMessageAt != null && DateTime.now().difference(lastMessageAt) > _sessionFreshness) {
        return (null, <AiChatMessage>[]);
      }
      final rows = await _sb.from('ai_chat_messages').select('role,body,status,response_kind,has_image,created_at,artifacts').eq('thread_id', id).order('created_at', ascending: true);
      final out = (rows as List).map((e) => AiChatMessage.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      await _persist(id, out);
      return (id, out);
    } catch (_) {
      return local;
    }
  }

  /// Appelle l'edge function en streaming SSE (Server-Sent Events) : chaque fragment de texte
  /// généré par le modèle arrive via [onDelta] au fur et à mesure, avant même que la réponse
  /// complète soit connue. Le [Future] ne se résout qu'à la réception de l'événement final
  /// ("done"), qui porte les métadonnées (response_kind, quiz, etc.) calculées côté serveur
  /// une fois toute la réponse générée.
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
    final token = _sb.auth.currentSession?.accessToken;
    final uri = Uri.parse('${Env.supabaseUrl}/functions/v1/ai-assistant-chat');
    final request = http.Request('POST', uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        'apikey': Env.supabasePublishableKey,
        if (token != null) 'Authorization': 'Bearer $token',
      })
      ..body = jsonEncode({
        'prompt': prompt,
        'threadId': threadId,
        'subjectId': subjectId,
        'chapterId': chapterId,
        if (image != null) 'image': {'mimeType': image.mimeType, 'dataBase64': base64Encode(image.bytes)},
        if (quizResult != null) 'quizResult': quizResult,
        if (mode != null) 'mode': mode,
      });

    final client = http.Client();
    final textBuffer = StringBuffer();
    final streamedArtifacts = <String, AiChatArtifact>{};
    Map<String, dynamic>? doneJson;
    try {
      final streamed = await client.send(request);
      if (streamed.statusCode != 200) {
        final errorBody = await streamed.stream.bytesToString();
        throw StateError('ai-assistant-chat ${streamed.statusCode}: $errorBody');
      }

      var pending = '';
      await for (final chunk in streamed.stream.transform(utf8.decoder)) {
        pending += chunk;
        // Un événement SSE se termine par une ligne vide ; un chunk réseau peut couper un
        // événement en plein milieu, d'où le tampon `pending` plutôt qu'un parsing chunk-par-chunk.
        while (pending.contains('\n\n')) {
          final idx = pending.indexOf('\n\n');
          final rawEvent = pending.substring(0, idx).trim();
          pending = pending.substring(idx + 2);
          if (!rawEvent.startsWith('data:')) continue;
          final payload = rawEvent.substring(5).trim();
          if (payload.isEmpty) continue;
          Map<String, dynamic> eventJson;
          try {
            eventJson = Map<String, dynamic>.from(jsonDecode(payload) as Map);
          } catch (_) {
            continue;
          }
          final delta = eventJson['delta'];
          if (delta is String && delta.isNotEmpty) {
            textBuffer.write(delta);
            onDelta?.call(delta);
          } else if (eventJson['artifact'] != null) {
            final a = AiChatArtifact.tryParse(eventJson['artifact']);
            if (a != null) {
              streamedArtifacts[a.id.isEmpty ? '${streamedArtifacts.length}' : a.id] = a;
              onArtifact?.call(a);
            }
          } else if (eventJson['tool'] is String) {
            onTool?.call('${eventJson['tool']}', '${eventJson['status'] ?? 'running'}');
          } else if (eventJson['done'] == true) {
            doneJson = eventJson;
          }
        }
      }
    } finally {
      client.close();
    }

    final json = doneJson ?? const <String, dynamic>{};
    // `text` (final, LaTeX normalisé côté serveur) prime sur l'accumulation
    // brute des deltas ; repli sur le flux si absent (edge function ancienne).
    final finalText = json['text'];
    final msg = AiChatMessage(
      role: 'assistant',
      body: finalText is String && finalText.trim().isNotEmpty
          ? finalText
          : textBuffer.toString(),
      createdAt: DateTime.now(),
      responseKind: '${json['response_kind'] ?? 'answer'}',
      hasImage: false,
      action: AiChatAction.tryParse(json['action']),
    );
    final quizJson = json['quiz'] as Map?;
    final quiz = quizJson == null ? null : AiQuizPayload.fromJson(Map<String, dynamic>.from(quizJson));
    // `done.artifacts` fait foi (liste complète, slimmée serveur) ; à défaut on
    // retombe sur ce qui a été reçu au fil de l'eau.
    final doneArtifacts = AiChatArtifact.listFrom(json['artifacts']);
    final artifacts = doneArtifacts.isNotEmpty
        ? doneArtifacts
        : streamedArtifacts.values.toList(growable: false);
    return AiAssistantReply(
      '${json['threadId'] ?? threadId ?? ''}',
      msg,
      json['cached'] == true,
      quiz,
      artifacts,
    );
  }

  Future<void> persist(String? threadId, List<AiChatMessage> messages) => _persist(threadId, messages);

  Future<(String?, List<AiChatMessage>)> _loadLocal() async {
    final threadRows = await _local.readList(_threadKey);
    final thread = threadRows == null || threadRows.isEmpty ? null : threadRows.first;
    final rows = await _local.readList(_messagesKey) ?? const [];
    return (thread?['id']?.toString(), rows.map((e) => AiChatMessage.fromJson(e)).toList());
  }

  Future<void> _persist(String? threadId, List<AiChatMessage> messages) async {
    await _local.writeList(_threadKey, [if (threadId != null) {'id': threadId}]);
    await _local.writeList(_messagesKey, messages.map((e) => e.toJson()).toList());
  }
}
