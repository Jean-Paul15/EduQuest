import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/features/home/presentation/widgets/access_banner.dart';
import 'package:eduquest/features/tickets/data/ticket_repository.dart';
import 'package:eduquest/features/tickets/presentation/ticket_activation_sheet.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('Tickets')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.l),
        children: [
          AccessBanner(access: _access),
          const SizedBox(height: AppSpace.l),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) =>
                    TicketActivationSheet(repository: TicketRepository()),
              ),
              icon: const Icon(Icons.confirmation_num_outlined),
              label: const Text('Activer un code ticket'),
            ),
          ),
        ],
      ),
    );
  }
}
