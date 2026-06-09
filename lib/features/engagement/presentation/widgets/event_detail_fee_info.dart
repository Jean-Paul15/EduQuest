import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/features/engagement/presentation/widgets/event_info_row.dart';

class EventDetailFeeInfo extends StatelessWidget {
  const EventDetailFeeInfo({
    super.key,
    required this.detail,
    required this.colorScheme,
  });

  final EngagementDetail detail;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventInfoRow(
          icon: PhosphorIconsRegular.currencyDollar,
          text: 'Participation ouverte • tarif selon ton ticket',
          colorScheme: colorScheme,
        ),
        EventInfoRow(
          icon: PhosphorIconsRegular.coins,
          text: 'FULL: ${detail.freeForFull == true ? 'Gratuit' : '${detail.feeFull?.toStringAsFixed(0) ?? '0'} FCFA'} • HALF: ${detail.feeHalf?.toStringAsFixed(0) ?? '0'} FCFA • FREE: ${detail.feeFree?.toStringAsFixed(0) ?? '0'} FCFA • CAMPAGNE: ${(detail.feeCampaignFree ?? detail.feeFree ?? 0).toStringAsFixed(0)} FCFA',
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}
