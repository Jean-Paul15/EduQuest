import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_outline_button.dart';

class EventActionButtons extends StatelessWidget {
  const EventActionButtons({
    super.key,
    required this.busy,
    required this.applied,
    required this.canPay,
    required this.onApply,
    required this.onPayShop,
  });

  final bool busy;
  final bool applied;
  final bool canPay;
  final VoidCallback onApply;
  final VoidCallback onPayShop;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: RuachSpace.s4),
        SizedBox(
          width: double.infinity,
          child: RuachButton(
            label: applied
                ? 'Déjà inscrit'
                : (canPay ? 'Reprendre le paiement' : 'Postuler'),
            onPressed: (busy || applied) ? null : onApply,
            icon: PhosphorIconsRegular.userCheck,
          ),
        ),
        if (canPay) ...[
          const SizedBox(height: RuachSpace.s2),
          SizedBox(
            width: double.infinity,
            child: RuachOutlineButton(
              label: 'Payer sur le site',
              onPressed: onPayShop,
              icon: PhosphorIconsRegular.browser,
            ),
          ),
        ],
      ],
    );
  }
}
