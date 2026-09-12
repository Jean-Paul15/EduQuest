import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_outline_button.dart';

class ContestDetailActionButtons extends StatelessWidget {
  const ContestDetailActionButtons({
    super.key,
    required this.isBusy,
    required this.hasApplied,
    required this.canPay,
    required this.isCancelled,
    required this.onJoin,
    required this.onCancel,
    required this.onPayOnSite,
  });

  final bool isBusy;
  final bool hasApplied;
  final bool canPay;
  final bool isCancelled;
  final VoidCallback onJoin;
  final VoidCallback onCancel;
  final VoidCallback onPayOnSite;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: RuachButton(
            label: hasApplied
                ? 'Déjà inscrit'
                : isCancelled
                ? 'Repostuler'
                : (canPay ? 'Reprendre le paiement' : 'Postuler'),
            loading: isBusy,
            onPressed: hasApplied ? null : onJoin,
            icon: PhosphorIconsRegular.userCheck,
          ),
        ),
        if (canPay) ...[
          const SizedBox(height: RuachSpace.s2),
          SizedBox(
            width: double.infinity,
            child: RuachOutlineButton(
              label: 'Payer sur le site',
              onPressed: onPayOnSite,
              icon: PhosphorIconsRegular.browser,
            ),
          ),
        ],
        if (hasApplied) ...[
          const SizedBox(height: RuachSpace.s2),
          SizedBox(
            width: double.infinity,
            child: RuachOutlineButton(
              label: 'Annuler ma postulation',
              onPressed: isBusy ? null : onCancel,
              icon: PhosphorIconsRegular.x,
            ),
          ),
        ],
      ],
    );
  }
}
