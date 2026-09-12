import 'package:eduquest/features/assistant/domain/ai_composer_attachment.dart';

/// Pré-remplissage de l'assistant depuis un autre écran (P2 « montre-moi ta
/// copie », réactivation d'une révision). Consommé une seule fois par
/// [AiAssistantPage] au montage ou à la réception, puis vidé du bus.
class AssistantSeed {
  const AssistantSeed({
    required this.prompt,
    this.image,
    this.subjectId,
    this.mode,
    this.presentDirectly = false,
  });

  final String prompt;
  final AiComposerAttachment? image;
  final String? subjectId;

  /// Transmis tel quel à l'edge function (ex. `copy_review`).
  final String? mode;

  /// Quand vrai, `prompt` n'apparaît PAS comme une bulle "élève" fabriquée
  /// dans le chat (ex. notification IA sur une méprise récurrente : l'élève
  /// n'a jamais tapé "j'ai du mal avec X", ce serait un faux aveu mis dans sa
  /// bouche) — seule la réponse de l'assistant s'affiche, comme s'il relançait
  /// lui-même la conversation.
  final bool presentDirectly;
}
