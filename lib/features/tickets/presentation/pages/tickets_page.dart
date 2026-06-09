import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/features/home/presentation/widgets/access_banner.dart';
import 'package:eduquest/features/tickets/data/ticket_repository.dart';
import 'package:eduquest/features/tickets/presentation/ticket_activation_sheet.dart';
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
  AccessState _access =
      const AccessState(tier: '...', hasAccess: false, expiresAt: null);

  @override
  void initState() {
    super.initState();
    AccessRepository().resolveAccess().then((value) {
      if (!mounted) return;
      setState(() => _access = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RuachAppBar(title: 'Tickets'),
      body: ListView(
        padding: const EdgeInsets.all(RuachSpace.s4),
        children: [
          AccessBanner(access: _access),
          const SizedBox(height: RuachSpace.s4),
          SizedBox(
            width: double.infinity,
            child: RuachButton(
              label: 'Activer un code ticket',
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) =>
                    TicketActivationSheet(repository: TicketRepository()),
              ),
              icon: PhosphorIconsRegular.ticket,
            ),
          ),
        ],
      ),
    );
  }
}
