import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/features/engagement/domain/event_pass.dart';
import 'package:eduquest/features/engagement/presentation/widgets/event_pass_card.dart';

class EventPassesSection extends StatelessWidget {
  const EventPassesSection({
    super.key,
    required this.passes,
    required this.colorScheme,
  });

  final List<EventPass> passes;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: RuachSpace.s6),
        const Text(
          'Mes billets',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: RuachColors.cream900,
          ),
        ),
        const SizedBox(height: RuachSpace.s2),
        if (passes.isEmpty)
          const EmptyState(
            title: 'Aucun billet détecté',
            subtitle: 'Après paiement sur le site, reviens ici puis actualise.',
            icon: PhosphorIconsRegular.ticket,
          )
        else
          ...passes.map(
            (p) => EventPassCard(pass: p, colorScheme: colorScheme),
          ),
      ],
    );
  }
}
