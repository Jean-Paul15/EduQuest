import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:eduquest/features/engagement/data/engagement_repository.dart';
import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/features/engagement/presentation/contest_detail_page.dart';
import 'package:eduquest/features/engagement/presentation/engagement_confirm_dialogs.dart';
import 'package:eduquest/shared/external/web_checkout_handoff.dart';
import 'package:eduquest/shared/ui/maps/external_maps_launcher.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/widgets/ticket_qr_dialog.dart';
import 'contest_detail_payment_flow.dart';

mixin ContestDetailLogic on State<ContestDetailPage> {
  final _repo = EngagementRepository();
  final _handoff = WebCheckoutHandoff();
  EngagementDetail? _detail;
  Map<String, dynamic>? _entry;
  bool _busy = false;
  EngagementDetail? get detail => _detail;
  Map<String, dynamic>? get entry => _entry;
  bool get busy => _busy;

  Future<void> load({bool forceRefresh = false, bool silent = false}) async {
    if (!silent) setState(() => _busy = true);
    final values = await Future.wait<dynamic>([
      _repo.contestDetail(widget.id, forceRefresh: forceRefresh),
      _repo.myContestEntry(widget.id, forceRefresh: forceRefresh),
    ]);
    if (!mounted) return;
    setState(() {
      _detail = values[0] as EngagementDetail;
      _entry = values[1] as Map<String, dynamic>?;
      _busy = false;
    });
  }

  Future<void> join() async {
    if (_busy) return;
    final ok = await confirmEngagementAction(
      context,
      title: 'Confirmer la postulation',
      message: 'Veux-tu postuler à ce concours maintenant ?',
      confirmLabel: 'Confirmer',
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final out = await _repo.joinContest(widget.id);
    if (!mounted) return;
    final fee = (out['fee_due'] as num?)?.toDouble() ?? 0;
    final needsPay = out['requires_payment'] == true || fee > 0;
    final success = out['success'] == true;
    final base = out['message']?.toString() ?? 'Opération effectuée.';
    final msg = !success
        ? base
        : needsPay
        ? '$base Montant à régler: ${fee.toStringAsFixed(0)} FCFA.'
        : 'Inscription prise en compte. Ton billet est disponible.';
    ModernSnackbar.show(context, msg, success: success);
    if (success && !needsPay) {
      final code = out['qr_code']?.toString() ?? '';
      if (code.isNotEmpty) {
        await showTicketQrDialog(context, title: 'Billet concours', code: code);
      }
    }
    if (success && needsPay) {
      if (!mounted) return;
      await handleContestJoinPayment(
        context: context,
        handoff: _handoff,
        contestId: widget.id,
        fee: fee,
        isMounted: () => mounted,
        reload: load,
      );
    }
    await load();
  }

  Future<void> cancel() async {
    if (_busy) return;
    final ok = await confirmEngagementAction(
      context,
      title: 'Annuler la participation',
      message: 'Tu pourras repostuler plus tard si le concours est encore ouvert.',
      confirmLabel: 'Annuler',
      cancelLabel: 'Garder ma place',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final out = await _repo.cancelContest(widget.id);
    if (!mounted) return;
    ModernSnackbar.show(
      context,
      out['message']?.toString() ?? 'Participation annulée.',
      success: out['success'] == true,
    );
    await load();
  }

  Future<void> openMaps() async {
    final d = _detail;
    if (d == null) return;
    final ok = await ExternalMapsLauncher.open(
      venue: d.venue ?? '',
      lat: d.locationLat,
      lng: d.locationLng,
    );
    if (!mounted || ok) return;
    ModernSnackbar.show(context, 'Impossible d\'ouvrir Maps.', success: false);
  }

  Future<void> payOnSite() async {
    final launched = await _handoff.openPayment(kind: 'contest', id: widget.id);
    if (launched) return;
    if (!mounted) return;
    ModernSnackbar.show(
      context,
      'Le service de paiement est indisponible pour le moment.',
      success: false,
    );
  }
}
