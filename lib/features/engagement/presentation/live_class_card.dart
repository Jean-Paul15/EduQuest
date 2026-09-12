import 'package:eduquest/features/engagement/domain/live_class_item.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/format/engagement_date_format.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LiveClassCard extends StatefulWidget {
  const LiveClassCard({super.key, required this.item, required this.onJoin});
  final LiveClassItem item;
  final Future<void> Function() onJoin;

  @override
  State<LiveClassCard> createState() => _LiveClassCardState();
}

class _LiveClassCardState extends State<LiveClassCard> {
  bool _joining = false;

  Future<void> _handleJoin() async {
    if (_joining) return;
    setState(() => _joining = true);
    try {
      await widget.onJoin();
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final item = widget.item;
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: s.outlineVariant),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(RuachSpace.s2),
            decoration: BoxDecoration(
              color: s.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(RuachRadius.sm),
            ),
            child: Icon(PhosphorIconsRegular.videoCamera, size: 20, color: s.primary),
          ),
          const SizedBox(width: RuachSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: s.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatEngagementDate(item.startsAt)} — ${formatEngagementDate(item.endsAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: s.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: RuachSpace.s2),
          RuachButton(label: 'Rejoindre', loading: _joining, onPressed: _handleJoin),
        ],
      ),
    );
  }
}
