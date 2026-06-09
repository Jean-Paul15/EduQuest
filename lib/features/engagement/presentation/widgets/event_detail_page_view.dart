import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/features/engagement/domain/event_pass.dart';
import 'package:eduquest/features/engagement/presentation/widgets/event_action_buttons.dart';
import 'package:eduquest/features/engagement/presentation/widgets/event_detail_fee_info.dart';
import 'package:eduquest/features/engagement/presentation/widgets/event_detail_header.dart';
import 'package:eduquest/features/engagement/presentation/widgets/event_passes_section.dart';
import 'package:eduquest/features/engagement/presentation/widgets/event_pending_payment_card.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';

class EventDetailPageView extends StatelessWidget {
  const EventDetailPageView({
    super.key,
    required this.detail,
    required this.colorScheme,
    required this.hasPass,
    required this.applied,
    required this.canPay,
    required this.pendingFee,
    required this.busy,
    required this.onRefresh,
    required this.onApply,
    required this.onPayShop,
    required this.openMeeting,
    required this.openMaps,
    required this.passes,
  });

  final EngagementDetail detail;
  final ColorScheme colorScheme;
  final bool hasPass;
  final bool applied;
  final bool canPay;
  final double? pendingFee;
  final bool busy;
  final VoidCallback onRefresh;
  final VoidCallback onApply;
  final VoidCallback onPayShop;
  final VoidCallback openMeeting;
  final VoidCallback openMaps;
  final List<EventPass> passes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RuachAppBar(
        title: 'Détail événement',
        actions: [
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(PhosphorIconsRegular.arrowsClockwise),
          ),
        ],
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(RuachSpace.s4),
        children: [
          EventDetailHeader(
            detail: detail,
            colorScheme: colorScheme,
            onMeeting: openMeeting,
            onMaps: openMaps,
          ),
          EventDetailFeeInfo(detail: detail, colorScheme: colorScheme),
          if (canPay) ...[
            const SizedBox(height: RuachSpace.s3),
            EventPendingPaymentCard(pendingFee: pendingFee),
          ],
          EventActionButtons(
            busy: busy,
            applied: applied,
            canPay: canPay,
            onApply: onApply,
            onPayShop: onPayShop,
          ),
          EventPassesSection(passes: passes, colorScheme: colorScheme),
        ],
      ),
    );
  }
}
