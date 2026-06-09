import 'package:eduquest/features/tickets/data/ticket_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TicketActivationSheet extends StatefulWidget {
  const TicketActivationSheet({
    super.key,
    required this.repository,
    this.onBuyTicket,
  });
  final TicketRepository repository;
  final VoidCallback? onBuyTicket;
  @override
  State<TicketActivationSheet> createState() => _TicketActivationSheetState();
}

class _TicketActivationSheetState extends State<TicketActivationSheet> {
  final _controller = TextEditingController();
  String _feedback = '';
  bool _loading = false;

  Future<void> _activate() async {
    setState(() => _loading = true);
    final result = await widget.repository.activateCode(
      _controller.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _feedback = result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        RuachSpace.s4,
        RuachSpace.s6,
        RuachSpace.s4,
        MediaQuery.of(context).viewInsets.bottom + RuachSpace.s4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Activer un ticket',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: RuachColors.cream900,
            ),
          ),
          const SizedBox(height: RuachSpace.s4),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Code ticket',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RuachRadius.md),
              ),
            ),
          ),
          const SizedBox(height: RuachSpace.s4),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _activate,
              icon: const Icon(PhosphorIconsRegular.sealCheck),
              label: Text(_loading ? 'Activation...' : 'Valider'),
            ),
          ),
          if (widget.onBuyTicket != null) ...[
            const SizedBox(height: RuachSpace.s2),
            SizedBox(
              width: double.infinity,
              child: RuachOutlineButton(
                label: 'Acheter un ticket sur le site',
                onPressed: widget.onBuyTicket,
                icon: PhosphorIconsRegular.shoppingCart,
              ),
            ),
          ],
          if (_feedback.isNotEmpty) ...[
            const SizedBox(height: RuachSpace.s3),
            Text(
              _feedback,
              textAlign: TextAlign.center,
              style: const TextStyle(color: RuachColors.cream500),
            ),
          ],
        ],
      ),
    );
  }
}
