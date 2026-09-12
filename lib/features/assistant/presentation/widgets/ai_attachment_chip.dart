import 'package:eduquest/features/assistant/domain/ai_composer_attachment.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class AiAttachmentChip extends StatelessWidget {
  const AiAttachmentChip({
    super.key,
    required this.attachment,
    required this.onRemove,
  });

  final AiComposerAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 40,
      padding: const EdgeInsets.only(left: RuachSpace.s1, right: RuachSpace.s2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(RuachRadius.sm),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(RuachRadius.sm - 2),
            child: Image.memory(
              attachment.bytes,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: RuachSpace.s2),
          Text(
            'Image jointe',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16),
            onPressed: onRemove,
            splashRadius: 16,
            tooltip: 'Retirer l\'image',
          ),
        ],
      ),
    );
  }
}
