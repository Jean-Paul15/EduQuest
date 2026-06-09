import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/features/engagement/domain/event_pass.dart';
import 'package:eduquest/features/engagement/presentation/event_detail_apply_actions.dart';
import 'package:eduquest/features/engagement/presentation/event_detail_nav_actions.dart';
import 'package:eduquest/features/engagement/presentation/widgets/event_action_buttons.dart';
import 'package:eduquest/features/engagement/presentation/widgets/event_detail_fee_info.dart';
import 'package:eduquest/features/engagement/presentation/widgets/event_detail_header.dart';
import 'package:eduquest/features/engagement/presentation/widgets/event_passes_section.dart';
import 'package:eduquest/features/engagement/presentation/widgets/event_pending_payment_card.dart';
import 'package:eduquest/shared/external/web_checkout_handoff.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key, required this.id});
  final String id;
  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage>
    with EventDetailNavActionsMixin, EventDetailApplyActionsMixin {
  final _repo = EngagementRepository();
  final _handoff = WebCheckoutHandoff();
  EngagementDetail? _detail;
  List<EventPass> _passes = const [];
  Map<String, dynamic>? _registration;
  bool _busy = false;
  @override
  WebCheckoutHandoff get handoff => _handoff;
  @override
  EngagementDetail? get detail => _detail;
  @override
  String get eventId => widget.id;
  @override
  EngagementRepository get repo => _repo;
  @override
  bool get busy => _busy;
  @override
  set busy(bool v) => setState(() => _busy = v);
  @override
  Future<void> reload() => _load();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _busy = true);
    final detail = await _repo.eventDetail(widget.id);
    final passes = await _repo.myEventPasses(widget.id);
    final registration = await _repo.myEventRegistration(widget.id);
    if (!mounted) return;
    setState(() {
      _detail = detail;
      _passes = passes;
      _registration = registration;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = _detail;
    final s = Theme.of(context).colorScheme;
    final hasPass = _passes.isNotEmpty;
    final regStatus = _registration?['status']?.toString() ?? '';
    final applied = regStatus == 'applied' || hasPass;
    final pending = regStatus == 'pending_payment';
    final pendingFee = (_registration?['attendance_fee'] as num?)?.toDouble();
    final canPay = pending && !applied && (pendingFee ?? 0) > 0;
    if (d == null || _busy) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: RuachAppBar(
        title: 'Détail événement',
        actions: [
          IconButton(onPressed: _load, icon: const Icon(PhosphorIconsRegular.arrowsClockwise)),
        ],
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(RuachSpace.s4),
        children: [
          EventDetailHeader(detail: d, colorScheme: s, onMeeting: openMeeting, onMaps: openMaps),
          EventDetailFeeInfo(detail: d, colorScheme: s),
          if (canPay) ...[
            const SizedBox(height: RuachSpace.s3),
            EventPendingPaymentCard(pendingFee: pendingFee),
          ],
          EventActionButtons(busy: _busy, applied: applied, canPay: canPay, onApply: apply, onPayShop: openShop),
          EventPassesSection(passes: _passes, colorScheme: s),
        ],
      ),
    );
  }
}
