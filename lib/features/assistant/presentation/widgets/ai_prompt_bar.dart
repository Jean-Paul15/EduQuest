import 'package:eduquest/features/assistant/domain/ai_composer_attachment.dart';
import 'package:eduquest/features/assistant/presentation/widgets/ai_attachment_chip.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class AiPromptBar extends StatelessWidget {
  const AiPromptBar({
    super.key,
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.onAttach,
    required this.onRemoveAttachment,
    this.attachment,
  });

  final TextEditingController controller;
  final bool sending;
  final Future<void> Function() onSend;
  final VoidCallback onAttach;
  final VoidCallback onRemoveAttachment;
  final AiComposerAttachment? attachment;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(RuachSpace.s3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: RuachMotion.appear,
                child: attachment == null
                    ? const SizedBox.shrink()
                    : Padding(
                        key: const ValueKey('attachment-chip'),
                        padding: const EdgeInsets.only(bottom: RuachSpace.s2),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AiAttachmentChip(
                            attachment: attachment!,
                            onRemove: onRemoveAttachment,
                          ),
                        ),
                      ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: sending ? null : onAttach,
                    icon: const Icon(Icons.image_outlined),
                    tooltip: 'Joindre une image',
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      decoration: const InputDecoration(
                        hintText: 'Pose une question sur tes cours',
                      ),
                    ),
                  ),
                  const SizedBox(width: RuachSpace.s2),
                  IconButton(
                    onPressed: sending ? null : () => onSend(),
                    icon: sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_upward_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
