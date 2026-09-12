import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/features/engagement/presentation/widgets/engagement_info_row.dart';
import 'package:eduquest/features/engagement/presentation/widgets/engagement_logo_banner.dart';

class EventDetailHeader extends StatelessWidget {
  const EventDetailHeader({
    super.key,
    required this.detail,
    required this.colorScheme,
    required this.onMeeting,
    required this.onMaps,
  });

  final EngagementDetail detail;
  final ColorScheme colorScheme;
  final VoidCallback onMeeting;
  final VoidCallback onMaps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EngagementLogoBanner(url: detail.logoUrl, tag: 'événement'),
        Text(
          detail.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: RuachSpace.s2),
        Text(
          detail.description,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        if (detail.venue?.isNotEmpty == true) ...[
          const SizedBox(height: RuachSpace.s2),
          EngagementInfoRow(icon: PhosphorIconsRegular.mapPin, text: detail.venue!),
        ],
        if ((detail.meetingUrl ?? '').isNotEmpty) ...[
          const SizedBox(height: RuachSpace.s2),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: onMeeting,
              icon: const Icon(PhosphorIconsRegular.videoCamera, size: 18),
              label: const Text('Rejoindre en ligne'),
            ),
          ),
        ],
        if ((detail.venue ?? '').isNotEmpty || detail.locationLat != null) ...[
          const SizedBox(height: RuachSpace.s2),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: onMaps,
              icon: const Icon(PhosphorIconsRegular.mapTrifold, size: 18),
              label: const Text('Ouvrir dans Maps'),
            ),
          ),
        ],
      ],
    );
  }
}
