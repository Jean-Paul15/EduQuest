import 'package:eduquest/features/orientation/domain/recommended_field.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

/// Carte d'une famille de filières. On met en avant l'explication rédigée par
/// l'IA ; les indicateurs chiffrés restent en arrière-plan, visuels et discrets.
class FieldCard extends StatelessWidget {
  const FieldCard({super.key, required this.field});
  final RecommendedField field;

  String get _eligibilityLabel => switch (field.eligibility) {
    EligibilityStatus.eligible => 'Accessible avec ta série',
    EligibilityStatus.eligibleWithBridge => 'Accessible via une passerelle',
    EligibilityStatus.ineligible => 'Non accessible avec ta série',
    EligibilityStatus.unknown => 'Conditions d’accès à vérifier',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final small = Theme.of(context).textTheme.bodySmall;
    return MergeSemantics(
      child: Container(
        margin: const EdgeInsets.only(bottom: RuachSpace.s3),
        padding: const EdgeInsets.all(RuachSpace.s4),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(RuachRadius.xl),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: RuachSpace.s1),
            Row(
              children: [
                Icon(Icons.verified_outlined, size: 14, color: scheme.primary),
                const SizedBox(width: RuachSpace.s1),
                Expanded(child: Text(_eligibilityLabel, style: small)),
              ],
            ),
            if ((field.justification ?? '').isNotEmpty) ...[
              const SizedBox(height: RuachSpace.s2),
              Text(field.justification!),
            ],
            if ((field.bridge ?? '').isNotEmpty) ...[
              const SizedBox(height: RuachSpace.s2),
              Text('Passerelle : ${field.bridge}', style: small),
            ],
            const SizedBox(height: RuachSpace.s3),
            _MiniGauges(
              compatibility: field.interestFit,
              feasibility: field.feasibility,
              confidence: field.dataConfidence,
            ),
          ],
        ),
      ),
    );
  }
}

/// Trois jauges fines sans chiffres : compatibilité, faisabilité, et fiabilité
/// des informations quand elle est connue.
class _MiniGauges extends StatelessWidget {
  const _MiniGauges({
    required this.compatibility,
    required this.feasibility,
    this.confidence,
  });
  final double compatibility, feasibility;
  final double? confidence;

  @override
  Widget build(BuildContext context) {
    final gauges = <(String, double)>[
      ('compatibilité', compatibility),
      ('faisabilité', feasibility),
      if (confidence != null) ('fiabilité des infos', confidence!),
    ];
    return Semantics(
      label: gauges
          .map((g) => '${g.$1} ${(g.$2.clamp(0, 1) * 100).round()} sur 100')
          .join(', '),
      child: Row(
        children: [
          for (final g in gauges) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(g.$1, style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(RuachRadius.full),
                    child: LinearProgressIndicator(
                      value: g.$2.clamp(0, 1),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
            if (g != gauges.last) const SizedBox(width: RuachSpace.s3),
          ],
        ],
      ),
    );
  }
}
