import 'package:eduquest/features/learning/domain/learning_subject.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SubjectTile extends StatelessWidget {
  const SubjectTile({
    super.key,
    required this.subject,
    required this.isOpening,
    required this.onTap,
  });

  final LearningSubject subject;
  final bool isOpening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: RuachColors.cream200),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: ListTile(
        title: Text(
          subject.label,
          style: const TextStyle(
            color: RuachColors.cream900,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isOpening
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(
                PhosphorIconsRegular.caretRight,
                color: RuachColors.cream700,
              ),
        onTap: onTap,
      ),
    );
  }
}
