import 'package:flutter/cupertino.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/features/engagement/domain/event_pass.dart';
import 'package:eduquest/features/engagement/presentation/widgets/engagement_logo_banner.dart';
import 'package:eduquest/shared/external/web_checkout_handoff.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/maps/external_maps_launcher.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ticket_qr_dialog.dart';
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
  final _handoff = WebCheckoutHandoff();
  EngagementDetail? _detail;
  List<EventPass> _passes = const [];
  Map<String, dynamic>? _registration;
  bool _busy = false;

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

  Future<void> _openShop() async {
    final launched = await _handoff.openPayment(kind: 'event', id: widget.id);
    if (launched || !mounted) return;
    ModernSnackbar.show(
      context,
      'Le service de paiement est indisponible pour le moment.',
      success: false,
    );
  }

  Future<void> _openMeeting() async {
    final url = _detail?.meetingUrl;
    if (url == null || url.isEmpty) {
      return ModernSnackbar.show(
        context,
        'Lien de réunion indisponible.',
        success: false,
      );
    }
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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

  Future<bool> _confirmApply() async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('Confirmer la postulation'),
        content: const Text('Veux-tu postuler à cet événement maintenant ?'),
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
    return ok == true;
  }

  Future<void> _apply() async {
    if (_busy) return;
    final ok = await _confirmApply();
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final out = await _repo.joinEvent(widget.id);
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
      final code = out['pass_code']?.toString() ?? '';
      if (code.isNotEmpty) {
        await showTicketQrDialog(
          context,
          title: 'Billet événement',
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
          kind: 'event',
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

  @override
  Widget build(BuildContext context) {
    final d = _detail;
    final s = Theme.of(context).colorScheme;
    final hasPass = _passes.isNotEmpty;
    final applied =
        (_registration?['status']?.toString() ?? '') == 'applied' || hasPass;
    final pending =
        (_registration?['status']?.toString() ?? '') == 'pending_payment';
    final pendingFee = (_registration?['attendance_fee'] as num?)?.toDouble();
    final canPay = pending && !applied && (pendingFee ?? 0) > 0;
    if (d == null || _busy) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail événement'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.l),
        children: [
          EngagementLogoBanner(url: d.logoUrl, tag: 'événement'),
          Text(
            d.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpace.s),
          Text(
            d.description,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (d.venue?.isNotEmpty == true) ...[
            const SizedBox(height: AppSpace.s),
            _infoRow(Icons.location_on_outlined, d.venue!, s),
          ],
          if ((d.meetingUrl ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpace.s),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: _openMeeting,
                icon: const Icon(Icons.video_call_rounded, size: 18),
                label: const Text('Rejoindre en ligne'),
              ),
            ),
          ],
          if ((d.venue ?? '').isNotEmpty || d.locationLat != null) ...[
            const SizedBox(height: AppSpace.s),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: _openMaps,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Ouvrir dans Maps'),
              ),
            ),
          ],
          _infoRow(
            Icons.payments_outlined,
            'Participation ouverte • tarif selon ton ticket',
            s,
          ),
          _infoRow(
            Icons.price_change_outlined,
            'FULL: ${d.freeForFull == true ? 'Gratuit' : '${d.feeFull?.toStringAsFixed(0) ?? '0'} FCFA'} • HALF: ${d.feeHalf?.toStringAsFixed(0) ?? '0'} FCFA • FREE: ${d.feeFree?.toStringAsFixed(0) ?? '0'} FCFA • CAMPAGNE: ${(d.feeCampaignFree ?? d.feeFree ?? 0).toStringAsFixed(0)} FCFA',
            s,
          ),
          if (canPay) ...[
            const SizedBox(height: AppSpace.m),
            Container(
              padding: const EdgeInsets.all(AppSpace.m),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statut: paiement en attente',
                    style: TextStyle(color: AppColors.accent),
                  ),
                  Text(
                    'Montant à payer: ${pendingFee?.toStringAsFixed(0) ?? '0'} FCFA',
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpace.l),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (_busy || applied) ? null : _apply,
              icon: const Icon(Icons.how_to_reg_rounded),
              label: Text(
                applied
                    ? 'Déjà inscrit'
                    : (canPay ? 'Reprendre le paiement' : 'Postuler'),
              ),
            ),
          ),
          if (canPay) ...[
            const SizedBox(height: AppSpace.s),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openShop,
                icon: const Icon(Icons.open_in_browser_rounded),
                label: const Text('Payer sur le site'),
              ),
            ),
          ],
          const SizedBox(height: AppSpace.xxl),
          const Text(
            'Mes billets',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpace.s),
          if (_passes.isEmpty)
            const EmptyState(
              title: 'Aucun billet détecté',
              subtitle:
                  'Après paiement sur le site, reviens ici puis actualise.',
              icon: Icons.confirmation_num_outlined,
            ),
          ..._passes.map((p) => _passCard(context, p, s)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, ColorScheme s) => Padding(
    padding: const EdgeInsets.only(top: AppSpace.s),
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

  Widget _passCard(BuildContext context, EventPass p, ColorScheme s) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: () => showTicketQrDialog(
        context,
        title: 'Billet événement',
        code: p.passCode,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpace.s),
        padding: const EdgeInsets.all(AppSpace.m),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpace.s),
              decoration: BoxDecoration(
                color: s.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Icon(Icons.qr_code_2_rounded, size: 22, color: s.primary),
            ),
            const SizedBox(width: AppSpace.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.passCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Billet généré le ${p.createdAt.toLocal()}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Touchez pour afficher le QR en grand',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
