import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/features/engagement/presentation/widgets/engagement_logo_banner.dart';
import 'package:eduquest/features/engagement/presentation/contest_detail_info_row.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';

class ContestDetailInfoSection extends StatelessWidget {
  const ContestDetailInfoSection({super.key, required this.detail, required this.onOpenMaps});

  final EngagementDetail detail;
  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    final d = detail;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EngagementLogoBanner(url: d.logoUrl, tag: 'concours'),
        Text(
          d.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: RuachColors.cream900),
        ),
        const SizedBox(height: RuachSpace.s3),
        ContestDetailInfoRow(icon: PhosphorIconsRegular.calendar, text: 'Debut: ${d.startsAt.toLocal()}'),
        if (d.endsAt != null)
          ContestDetailInfoRow(icon: PhosphorIconsRegular.calendar, text: 'Fin: ${d.endsAt!.toLocal()}'),
        ContestDetailInfoRow(
          icon: d.isInPerson == true ? PhosphorIconsRegular.mapPin : PhosphorIconsRegular.globe,
          text: d.isInPerson == true ? 'Présentiel' : 'En ligne',
        ),
        if ((d.venue ?? '').isNotEmpty) ContestDetailInfoRow(icon: PhosphorIconsRegular.mapPin, text: d.venue!),
        if ((d.venue ?? '').isNotEmpty || d.locationLat != null)
          Padding(
            padding: const EdgeInsets.only(bottom: RuachSpace.s2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: onOpenMaps,
                icon: const Icon(PhosphorIconsRegular.mapTrifold, size: 18),
                label: const Text('Ouvrir dans Maps'),
              ),
            ),
          ),
        ContestDetailInfoRow(
          icon: PhosphorIconsRegular.currencyDollar,
          text: 'Participation ouverte • tarif selon ton ticket',
        ),
        ContestDetailInfoRow(
          icon: PhosphorIconsRegular.coins,
          text: 'FULL: ${d.freeForFull == true ? 'Gratuit' : '${d.feeFull?.toStringAsFixed(0) ?? '0'} FCFA'} • HALF: ${d.feeHalf?.toStringAsFixed(0) ?? '0'} FCFA • FREE: ${d.feeFree?.toStringAsFixed(0) ?? '0'} FCFA • CAMPAGNE: ${(d.feeCampaignFree ?? d.feeFree ?? 0).toStringAsFixed(0)} FCFA',
        ),
        const SizedBox(height: RuachSpace.s4),
        MarkdownBody(data: d.description),
        if (d.requireWhatsapp == true)
          const Padding(
            padding: EdgeInsets.only(top: RuachSpace.s4),
            child: Text(
              'Le numéro WhatsApp du profil est requis pour postuler.',
              style: TextStyle(color: RuachColors.cream500),
            ),
          ),
      ],
    );
  }
}
