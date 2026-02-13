import 'package:eduquest/features/tickets/data/ticket_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

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
        AppSpace.l,
        AppSpace.xxl,
        AppSpace.l,
        MediaQuery.of(context).viewInsets.bottom + AppSpace.l,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Activer un ticket',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpace.l),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Code ticket',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.l),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _activate,
              icon: const Icon(Icons.verified_rounded),
              label: Text(_loading ? 'Activation...' : 'Valider'),
            ),
          ),
          if (widget.onBuyTicket != null) ...[
            const SizedBox(height: AppSpace.s),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onBuyTicket,
                icon: const Icon(Icons.shopping_cart_checkout_rounded),
                label: const Text('Acheter un ticket sur le site'),
              ),
            ),
          ],
          if (_feedback.isNotEmpty) ...[
            const SizedBox(height: AppSpace.m),
            Text(
              _feedback,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
