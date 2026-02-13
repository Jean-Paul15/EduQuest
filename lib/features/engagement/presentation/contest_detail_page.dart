import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ContestDetailPage extends StatefulWidget {
  const ContestDetailPage({super.key, required this.id});
  final String id;
  @override
  State<ContestDetailPage> createState() => _ContestDetailPageState();
}

class _ContestDetailPageState extends State<ContestDetailPage> {
  final _repo = EngagementRepository();
  EngagementDetail? _detail;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _repo.contestDetail(widget.id).then(
      (v) => mounted ? setState(() => _detail = v) : null,
    );
  }

  Future<void> _join() async {
    if (_busy) return;
    setState(() => _busy = true);
    final msg = await _repo.joinContest(widget.id);
    if (!mounted) return;
    setState(() => _busy = false);
    final ok = !msg.toLowerCase().contains('insuffisant') &&
        !msg.toLowerCase().contains('introuvable') &&
        !msg.toLowerCase().contains('non accessible');
    ModernSnackbar.show(context, msg, success: ok);
  }

  @override
  Widget build(BuildContext context) {
    final d = _detail;
    if (d == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Detail concours')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.l),
        children: [
          Text(
            d.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpace.m),
          _row(Icons.calendar_today_rounded, 'Debut: ${d.startsAt.toLocal()}'),
          if (d.endsAt != null)
            _row(Icons.event_rounded, 'Fin: ${d.endsAt!.toLocal()}'),
          _row(
            d.isInPerson == true ? Icons.place_rounded : Icons.language_rounded,
            d.isInPerson == true ? 'Presentiel' : 'En ligne',
          ),
          if ((d.venue ?? '').isNotEmpty)
            _row(Icons.location_on_outlined, d.venue!),
          if (d.requiredTicketType != null)
            _row(Icons.confirmation_num_outlined, 'Ticket: ${d.requiredTicketType}'),
          const SizedBox(height: AppSpace.l),
          MarkdownBody(data: d.description),
          const SizedBox(height: AppSpace.xxl),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _busy ? null : _join,
              icon: const Icon(Icons.how_to_reg_rounded),
              label: Text(_busy ? 'Postulation...' : 'Postuler'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    final s = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(AppSpace.s),
          decoration: BoxDecoration(
            color: s.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Icon(icon, size: 18, color: s.primary),
        ),
        const SizedBox(width: AppSpace.m),
        Expanded(
          child: Text(text, style: const TextStyle(color: AppColors.textSecondary)),
        ),
      ]),
    );
  }
}
