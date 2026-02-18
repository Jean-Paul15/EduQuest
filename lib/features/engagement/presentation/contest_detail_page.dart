import 'package:flutter/cupertino.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/features/engagement/presentation/widgets/engagement_logo_banner.dart';
import 'package:eduquest/shared/external/web_checkout_handoff.dart';
import 'package:eduquest/shared/ui/maps/external_maps_launcher.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/widgets/ticket_qr_dialog.dart';
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
  final _handoff = WebCheckoutHandoff();
  EngagementDetail? _detail;
  Map<String, dynamic>? _entry;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _busy = true);
    final d = await _repo.contestDetail(widget.id);
    final e = await _repo.myContestEntry(widget.id);
    if (!mounted) return;
    setState(() {
      _detail = d;
      _entry = e;
      _busy = false;
    });
  }

  Future<void> _join() async {
    if (_busy) return;
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Confirmer la postulation'),
        content: const Text('Veux-tu postuler à ce concours maintenant ?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Annuler'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final out = await _repo.joinContest(widget.id);
    if (!mounted) return;
    final fee = (out['fee_due'] as num?)?.toDouble() ?? 0;
    final needsPay = out['requires_payment'] == true || fee > 0;
    final base = out['message']?.toString() ?? 'Opération effectuée.';
    final success = out['success'] == true;
    final msg = !success
        ? base
        : needsPay
        ? '$base Montant à régler: ${fee.toStringAsFixed(0)} FCFA.'
        : 'Inscription prise en compte. Ton billet est disponible.';
    ModernSnackbar.show(context, msg, success: success);
    if (success && !needsPay) {
      final code = out['qr_code']?.toString() ?? '';
      if (code.isNotEmpty) {
        await showTicketQrDialog(
          context,
          title: 'Billet concours',
          code: code,
        );
      }
    }
    if (success && needsPay) {
      if (!mounted) return;
      final go = await showCupertinoDialog<bool>(
        context: context,
        builder: (dialogCtx) => CupertinoAlertDialog(
          title: const Text('Paiement requis'),
          content: Text(
            'Tu vas être redirigé vers le site pour payer ${fee.toStringAsFixed(0)} FCFA.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Plus tard'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Payer maintenant'),
            ),
          ],
        ),
      );
      if (go == true) {
        final launched = await _handoff.openPayment(
          kind: 'contest',
          id: widget.id,
        );
        if (!launched) {
          if (!mounted) return;
          ModernSnackbar.show(
            context,
            'Le service de paiement est indisponible pour le moment.',
            success: false,
          );
        }
      }
    }
    await _load();
  }

  Future<void> _cancel() async {
    if (_busy) return;
    setState(() => _busy = true);
    final msg = await _repo.cancelContest(widget.id);
    if (!mounted) return;
    ModernSnackbar.show(context, msg, success: !msg.contains('Aucune'));
    await _load();
  }

  Future<void> _openMaps() async {
    final d = _detail;
    if (d == null) return;
    final ok = await ExternalMapsLauncher.open(
      venue: d.venue ?? '',
      lat: d.locationLat,
      lng: d.locationLng,
    );
    if (!mounted || ok) return;
    ModernSnackbar.show(context, 'Impossible d’ouvrir Maps.', success: false);
  }

  @override
  Widget build(BuildContext context) {
    final d = _detail;
    if (d == null || _busy) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final qr = _entry?['qr_code']?.toString();
    final pending = (_entry?['status']?.toString() ?? '') == 'pending_payment';
    final fee = (_entry?['attendance_fee'] as num?)?.toDouble();
    final applied =
        (_entry?['status']?.toString() ?? '') == 'applied' ||
        ((qr ?? '').isNotEmpty);
    final canPay = pending && !applied && (fee ?? 0) > 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail concours'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.l),
        children: [
          EngagementLogoBanner(url: d.logoUrl, tag: 'concours'),
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
            d.isInPerson == true ? 'Présentiel' : 'En ligne',
          ),
          if ((d.venue ?? '').isNotEmpty)
            _row(Icons.location_on_outlined, d.venue!),
          if ((d.venue ?? '').isNotEmpty || d.locationLat != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.s),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  onPressed: _openMaps,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Ouvrir dans Maps'),
                ),
              ),
            ),
          _row(
            Icons.payments_outlined,
            'Participation ouverte • tarif selon ton ticket',
          ),
          _row(
            Icons.price_change_outlined,
            'FULL: ${d.freeForFull == true ? 'Gratuit' : '${d.feeFull?.toStringAsFixed(0) ?? '0'} FCFA'} • HALF: ${d.feeHalf?.toStringAsFixed(0) ?? '0'} FCFA • FREE: ${d.feeFree?.toStringAsFixed(0) ?? '0'} FCFA • CAMPAGNE: ${(d.feeCampaignFree ?? d.feeFree ?? 0).toStringAsFixed(0)} FCFA',
          ),
          const SizedBox(height: AppSpace.l),
          MarkdownBody(data: d.description),
          if (d.requireWhatsapp == true)
            const Padding(
              padding: EdgeInsets.only(top: AppSpace.l),
              child: Text(
                'Le numéro WhatsApp du profil est requis pour postuler.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          if (applied) ...[
            const SizedBox(height: AppSpace.l),
            Container(
              padding: const EdgeInsets.all(AppSpace.m),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statut: appliqué',
                    style: TextStyle(color: AppColors.success),
                  ),
                  if (fee != null && fee > 0)
                    Text(
                      'Montant réglé: ${fee.toStringAsFixed(0)} FCFA',
                    ),
                  if ((qr ?? '').isNotEmpty) ...[
                    const SizedBox(height: AppSpace.s),
                    OutlinedButton.icon(
                      onPressed: () => showTicketQrDialog(
                        context,
                        title: 'Billet concours',
                        code: qr!,
                      ),
                      icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                      label: const Text('Afficher le QR en grand'),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (canPay) ...[
            const SizedBox(height: AppSpace.l),
            Container(
              padding: const EdgeInsets.all(AppSpace.m),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statut: paiement en attente',
                    style: TextStyle(color: AppColors.accent),
                  ),
                  Text(
                    'Montant à payer: ${fee?.toStringAsFixed(0) ?? '0'} FCFA',
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpace.xxl),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (_busy || applied) ? null : _join,
              icon: const Icon(Icons.how_to_reg_rounded),
              label: Text(
                _busy
                    ? 'Postulation...'
                    : (applied
                          ? 'Déjà inscrit'
                          : (canPay ? 'Reprendre le paiement' : 'Postuler')),
              ),
            ),
          ),
          if (canPay) ...[
            const SizedBox(height: AppSpace.s),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final launched = await _handoff.openPayment(
                    kind: 'contest',
                    id: widget.id,
                  );
                  if (!launched) {
                    if (!context.mounted) return;
                    ModernSnackbar.show(
                      context,
                      'Le service de paiement est indisponible pour le moment.',
                      success: false,
                    );
                  }
                },
                icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                label: const Text('Payer sur le site'),
              ),
            ),
          ],
          if (applied) ...[
            const SizedBox(height: AppSpace.s),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _cancel,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Annuler ma postulation'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    final s = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s),
      child: Row(
        children: [
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
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
