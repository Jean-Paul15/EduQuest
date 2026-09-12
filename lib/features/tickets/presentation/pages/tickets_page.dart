import 'dart:async';
import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/features/home/presentation/widgets/access_banner.dart';
import 'package:eduquest/features/tickets/data/ticket_repository.dart';
import 'package:eduquest/features/tickets/presentation/ticket_activation_sheet.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/sync/service_locator.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});
  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  final _accessRepo = ServiceLocator().accessRepo;
  final _analytics = AppAnalytics();
  StreamSubscription<AccessState>? _sub;
  AccessState _access = const AccessState(
    tier: '...',
    hasAccess: false,
    expiresAt: null,
    source: 'loading',
  );
  bool _activating = false;

  Future<void> _openActivation() async {
    if (_activating) return;
    unawaited(_analytics.track('ticket_activation_opened', category: 'ticket'));
    setState(() => _activating = true);
    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => TicketActivationSheet(repository: TicketRepository()),
      );
      _accessRepo.refresh();
    } finally {
      if (mounted) setState(() => _activating = false);
    }
  }

  @override
  void initState() {
    super.initState();
    unawaited(_analytics.track('tickets_opened', category: 'ticket'));
    _access = _accessRepo.lastKnownAccess;
    _sub = _accessRepo.accessStream.listen((s) {
      if (!mounted) return;
      setState(() => _access = s);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RuachAppBar(title: 'Tickets', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(RuachSpace.s4),
        children: [
          AccessBanner(access: _access),
          const SizedBox(height: RuachSpace.s4),
          SizedBox(
            width: double.infinity,
            child: RuachButton(
              label: 'Activer un code ticket',
              loading: _activating,
              onPressed: _openActivation,
              icon: PhosphorIconsRegular.ticket,
            ),
          ),
        ],
      ),
    );
  }
}
