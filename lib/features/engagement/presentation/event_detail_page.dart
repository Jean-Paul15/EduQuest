import 'dart:async';
import 'package:flutter/material.dart';

import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/features/engagement/domain/event_pass.dart';
import 'package:eduquest/features/engagement/presentation/event_detail_apply_actions.dart';
import 'package:eduquest/features/engagement/presentation/event_detail_nav_actions.dart';
import 'package:eduquest/features/engagement/presentation/widgets/event_detail_page_view.dart';
import 'package:eduquest/shared/external/web_checkout_handoff.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
    unawaited(_load(forceRefresh: true, silent: true));
  }

  Future<void> _load({bool forceRefresh = false, bool silent = false}) async {
    if (!silent) setState(() => _busy = true);
    final values = await Future.wait<dynamic>([
      _repo.eventDetail(widget.id, forceRefresh: forceRefresh),
      _repo.myEventPasses(widget.id, forceRefresh: forceRefresh),
      _repo.myEventRegistration(widget.id, forceRefresh: forceRefresh),
    ]);
    if (!mounted) return;
    setState(() {
      _detail = values[0] as EngagementDetail;
      _passes = values[1] as List<EventPass>;
      _registration = values[2] as Map<String, dynamic>?;
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
    if (d == null) {
      return const Scaffold(
        appBar: RuachAppBar(title: 'Détail événement', showBack: true),
        body: _EventDetailSkeleton(),
      );
    }
    if (d.title == 'Événement indisponible') {
      return Scaffold(
        appBar: const RuachAppBar(title: 'Détail événement', showBack: true),
        body: RuachEmptyState(
          icon: PhosphorIconsRegular.calendarX,
          title: 'Événement indisponible',
          subtitle: d.description,
          actionLabel: 'Réessayer',
          onAction: _busy ? null : _load,
        ),
      );
    }
    return EventDetailPageView(
      detail: d,
      colorScheme: s,
      hasPass: hasPass,
      applied: applied,
      canPay: canPay,
      pendingFee: pendingFee,
      busy: _busy,
      onRefresh: _load,
      onApply: apply,
      onPayShop: openShop,
      openMeeting: openMeeting,
      openMaps: openMaps,
      passes: _passes,
    );
  }
}

class _EventDetailSkeleton extends StatelessWidget {
  const _EventDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(RuachSpace.s4),
      children: [
        RuachSkeleton(
          child: Container(
            height: 232,
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
            height: 140,
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
