import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/features/engagement/domain/event_pass.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key, required this.id});
  final String id;
  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final _repo = EngagementRepository();
  EngagementDetail? _detail;
  List<EventPass> _passes = const [];
  bool _busy = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _busy = true);
    final detail = await _repo.eventDetail(widget.id);
    final passes = await _repo.myEventPasses(widget.id);
    if (!mounted) return;
    setState(() { _detail = detail; _passes = passes; _busy = false; });
  }

  Future<void> _openShop() async {
    final url = _detail?.externalUrl;
    if (url == null || url.isEmpty) {
      return ModernSnackbar.show(context, 'Lien de paiement indisponible.', success: false);
    }
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final d = _detail;
    final s = Theme.of(context).colorScheme;
    if (d == null || _busy) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail evenement'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: ListView(padding: const EdgeInsets.all(AppSpace.l), children: [
        Text(d.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: AppSpace.s),
        Text(d.description, style: const TextStyle(color: AppColors.textSecondary)),
        if (d.venue?.isNotEmpty == true) ...[
          const SizedBox(height: AppSpace.s),
          _infoRow(Icons.location_on_outlined, d.venue!, s),
        ],
        if (d.requiredTicketType != null)
          _infoRow(Icons.confirmation_num_outlined, 'Ticket: ${d.requiredTicketType}', s),
        const SizedBox(height: AppSpace.l),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _openShop,
            icon: const Icon(Icons.open_in_browser_rounded),
            label: const Text('Payer sur le site'),
          ),
        ),
        const SizedBox(height: AppSpace.xxl),
        const Text('Mes billets payes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: AppSpace.s),
        if (_passes.isEmpty)
          const EmptyState(title: 'Aucun billet detecte', subtitle: 'Apres paiement sur le site, reviens ici puis actualise.', icon: Icons.confirmation_num_outlined),
        ..._passes.map((p) => _passCard(p, s)),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String text, ColorScheme s) => Padding(
    padding: const EdgeInsets.only(top: AppSpace.s),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(AppSpace.s),
        decoration: BoxDecoration(color: s.primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(AppRadius.xs)),
        child: Icon(icon, size: 18, color: s.primary),
      ),
      const SizedBox(width: AppSpace.m),
      Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary))),
    ]),
  );

  Widget _passCard(EventPass p, ColorScheme s) => Container(
    margin: const EdgeInsets.only(bottom: AppSpace.s),
    padding: const EdgeInsets.all(AppSpace.m),
    decoration: BoxDecoration(color: Theme.of(context).cardColor, border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(AppRadius.card)),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(AppSpace.s),
        decoration: BoxDecoration(color: s.primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(AppRadius.xs)),
        child: Icon(Icons.qr_code_2_rounded, size: 22, color: s.primary),
      ),
      const SizedBox(width: AppSpace.m),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.passCode, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text('Achete le ${p.createdAt.toLocal()}', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
      ])),
    ]),
  );
}
