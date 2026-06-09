import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ticket_qr_dialog.dart';
import 'package:eduquest/features/engagement/domain/event_pass.dart';

class EventPassCard extends StatelessWidget {
  const EventPassCard({
    super.key,
    required this.pass,
    required this.colorScheme,
  });

  final EventPass pass;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        onTap: () => showTicketQrDialog(
          context,
          title: 'Billet événement',
          code: pass.passCode,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: RuachSpace.s2),
          padding: const EdgeInsets.all(RuachSpace.s3),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: RuachColors.cream200),
            borderRadius: BorderRadius.circular(RuachRadius.lg),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(RuachSpace.s2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(RuachRadius.sm),
                ),
                child: Icon(
                  PhosphorIconsRegular.qrCode,
                  size: 22,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: RuachSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pass.passCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: RuachColors.cream900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Billet généré le ${pass.createdAt.toLocal()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: RuachColors.cream700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Touchez pour afficher le QR en grand',
                      style: TextStyle(
                        fontSize: 12,
                        color: RuachColors.cream500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
