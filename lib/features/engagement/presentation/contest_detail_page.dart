import 'package:eduquest/features/engagement/presentation/contest_detail_action_buttons.dart';
import 'package:eduquest/features/engagement/presentation/contest_detail_info_section.dart';
import 'package:eduquest/features/engagement/presentation/contest_detail_logic.dart';
import 'package:eduquest/features/engagement/presentation/contest_detail_status_cards.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ContestDetailPage extends StatefulWidget {
  const ContestDetailPage({super.key, required this.id});
  final String id;
  @override
  State<ContestDetailPage> createState() => _ContestDetailPageState();
}

class _ContestDetailPageState extends State<ContestDetailPage> with ContestDetailLogic {
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final d = detail;
    if (d == null || busy) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final qr = entry?['qr_code']?.toString();
    final pending = (entry?['status']?.toString() ?? '') == 'pending_payment';
    final fee = (entry?['attendance_fee'] as num?)?.toDouble();
    final applied = (entry?['status']?.toString() ?? '') == 'applied' || ((qr ?? '').isNotEmpty);
    final canPay = pending && !applied && (fee ?? 0) > 0;
    return Scaffold(
      appBar: RuachAppBar(
        title: 'Détail concours',
        actions: [IconButton(onPressed: load, icon: const Icon(PhosphorIconsRegular.arrowsClockwise))],
        showBack: true,
      ),
      body: ListView(
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
          const SizedBox(height: RuachSpace.s6),
          ContestDetailActionButtons(
            isBusy: busy,
            hasApplied: applied,
            canPay: canPay,
            onJoin: join,
            onCancel: cancel,
            onPayOnSite: payOnSite,
          ),
        ],
      ),
    );
  }
}
