import 'dart:async';
import 'package:eduquest/features/engagement/presentation/contest_detail_action_buttons.dart';
import 'package:eduquest/features/engagement/presentation/contest_detail_info_section.dart';
import 'package:eduquest/features/engagement/presentation/contest_detail_logic.dart';
import 'package:eduquest/features/engagement/presentation/contest_detail_status_cards.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ContestDetailPage extends StatefulWidget {
  const ContestDetailPage({super.key, required this.id});
  final String id;
  @override
  State<ContestDetailPage> createState() => _ContestDetailPageState();
}

class _ContestDetailPageState extends State<ContestDetailPage>
    with ContestDetailLogic {
  @override
  void initState() {
    super.initState();
    load();
    unawaited(load(forceRefresh: true, silent: true));
  }

  @override
  Widget build(BuildContext context) {
    final d = detail;
    if (d == null) {
      return const Scaffold(
        appBar: RuachAppBar(title: 'Détail concours', showBack: true),
        body: _ContestDetailSkeleton(),
      );
    }
    final qr = entry?['qr_code']?.toString();
    final status = entry?['status']?.toString() ?? '';
    final pending = status == 'pending_payment';
    final fee = (entry?['attendance_fee'] as num?)?.toDouble();
    final cancelled = status == 'cancelled';
    final applied =
        status == 'applied' ||
        ((qr ?? '').isNotEmpty);
    final canPay = pending && !applied && (fee ?? 0) > 0;
    final unavailable = d.title == 'Concours indisponible';
    return Scaffold(
      appBar: RuachAppBar(
        title: 'Détail concours',
        actions: [
          IconButton(
            onPressed: busy ? null : load,
            icon: const Icon(PhosphorIconsRegular.arrowsClockwise),
          ),
        ],
        showBack: true,
      ),
      body: unavailable
          ? RuachEmptyState(
              icon: PhosphorIconsRegular.trophy,
              title: 'Concours indisponible',
              subtitle: d.description,
              actionLabel: 'Réessayer',
              onAction: busy ? null : load,
            )
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(
                padding: const EdgeInsets.all(RuachSpace.s4),
                children: [
                  ContestDetailInfoSection(detail: d, onOpenMaps: openMaps),
                  if (applied) ...[
                    const SizedBox(height: RuachSpace.s4),
                    ContestDetailAppliedCard(fee: fee, qrCode: qr),
                  ],
                  if (canPay) ...[
                    const SizedBox(height: RuachSpace.s4),
                    ContestDetailPendingPaymentCard(fee: fee),
                  ],
                  if (cancelled) ...[
                    const SizedBox(height: RuachSpace.s4),
                    const ContestDetailCancelledCard(),
                  ],
                  const SizedBox(height: RuachSpace.s6),
                  ContestDetailActionButtons(
                    isBusy: busy,
                    hasApplied: applied,
                    canPay: canPay,
                    isCancelled: cancelled,
                    onJoin: join,
                    onCancel: cancel,
                    onPayOnSite: payOnSite,
                  ),
                ],
              ),
            ),
    );
  }
}

class _ContestDetailSkeleton extends StatelessWidget {
  const _ContestDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(RuachSpace.s4),
      children: [
        RuachSkeleton(
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(RuachRadius.xl),
              border: Border.all(color: scheme.outlineVariant),
            ),
          ),
        ),
        const SizedBox(height: RuachSpace.s4),
        RuachSkeleton(
          child: Container(
            height: 96,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(RuachRadius.xl),
              border: Border.all(color: scheme.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }
}
