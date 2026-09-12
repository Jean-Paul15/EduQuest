import 'ai_chat_action.dart';
import 'ai_chat_artifact.dart';
import 'ai_quiz_payload.dart';

class AiChatMessage {
  const AiChatMessage({
    required this.role,
    required this.body,
    required this.createdAt,
    this.status = 'ready',
    this.responseKind = 'answer',
    this.hasImage = false,
    this.quiz,
    this.artifacts = const [],
    this.action,
  });

  final String role;
  final String body;
  final DateTime createdAt;
  final String status;
  final String responseKind;
  final bool hasImage;
  // Transitoire : présent uniquement sur la réponse fraîche du serveur qui vient de lancer un quiz,
  // jamais reconstruit depuis l'historique persisté (ai_chat_messages n'a pas de colonne dédiée).
  final AiQuizPayload? quiz;

  /// Cartes de résultats calculés (courbe, valeur, solution). Persistées dans
  /// `ai_chat_messages.artifacts` — donc rechargées avec l'historique.
  final List<AiChatArtifact> artifacts;

  /// Action de navigation in-app (ex. ouvrir la liste des épreuves d'une
  /// matière). Rejouée depuis le cache local ; absente au rechargement
  /// depuis Supabase (pas de colonne dédiée, comme `quiz`).
  final AiChatAction? action;

  bool get isAssistant => role == 'assistant';

  factory AiChatMessage.fromJson(Map<String, dynamic> json) => AiChatMessage(
    role: '${json['role'] ?? 'assistant'}',
    body: '${json['body'] ?? ''}',
    createdAt:
        DateTime.tryParse('${json['created_at'] ?? ''}') ?? DateTime.now(),
    status: '${json['status'] ?? 'ready'}',
    responseKind: '${json['response_kind'] ?? 'answer'}',
    hasImage: json['has_image'] == true,
    artifacts: AiChatArtifact.listFrom(json['artifacts']),
    action: AiChatAction.tryParse(json['action']),
  );

  Map<String, dynamic> toJson() => {
    'role': role,
    'body': body,
    'created_at': createdAt.toUtc().toIso8601String(),
    'status': status,
    'response_kind': responseKind,
    'has_image': hasImage,
    'artifacts': artifacts.map((a) => a.toJson()).toList(),
    if (action != null) 'action': action!.toJson(),
  };
}
