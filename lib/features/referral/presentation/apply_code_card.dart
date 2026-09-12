import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ApplyCodeCard extends StatelessWidget {
  const ApplyCodeCard({
    super.key,
    required this.codeCtrl,
    required this.loading,
    required this.onApply,
  });

  final TextEditingController codeCtrl;
  final bool loading;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          TextField(
            controller: codeCtrl,
            decoration: const InputDecoration(hintText: 'Code parrain'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: RuachButton(
              label: 'Appliquer',
              loading: loading,
              onPressed: onApply,
              icon: PhosphorIconsRegular.gift,
            ),
          ),
        ],
      ),
    );
  }
}
