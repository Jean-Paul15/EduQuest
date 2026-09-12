import 'package:eduquest/features/assistant/domain/ai_chat_action.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

/// Bouton d'action attaché à une réponse de l'assistant (ex. « Voir les
/// épreuves »). Volontairement discret — teinte primaire légère, plein
/// largeur, chevron de navigation — pour se fondre dans la bulle sans
/// détourner l'attention du texte.
class AiMessageActionButton extends StatelessWidget {
  const AiMessageActionButton({
    super.key,
    required this.action,
    required this.onTap,
  });

  final AiChatAction action;
  final VoidCallback onTap;

  IconData get _icon =>
      action.isOpenChapter ? Icons.menu_book_outlined : Icons.description_outlined;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: action.label,
      child: Material(
        color: scheme.primary.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(RuachRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: RuachSpace.s3,
              vertical: RuachSpace.s2,
            ),
            child: Row(
              children: [
                Icon(_icon, size: 18, color: scheme.primary),
                const SizedBox(width: RuachSpace.s2),
                Expanded(
                  child: Text(
                    action.label,
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, size: 16, color: scheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
