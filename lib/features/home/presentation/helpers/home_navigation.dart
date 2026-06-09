import 'package:eduquest/features/home/domain/home_snapshot.dart';
import 'package:eduquest/features/home/presentation/home_controller.dart';
import 'package:eduquest/features/tickets/presentation/ticket_activation_sheet.dart';
import 'package:eduquest/features/tickets/data/ticket_repository.dart';
import 'package:eduquest/shared/external/web_checkout_handoff.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

mixin HomeNavigationMixin<T extends StatefulWidget> on State<T> {
  WebCheckoutHandoff get handoff;
  String get supportUrl;
  HomeController get controller;
  void applySnapshot(HomeSnapshot s);

  Future<void> openExternal(String url, String fallback) async {
    final target = url.trim().isEmpty ? fallback : url.trim();
    if (target.isEmpty) {
      if (!mounted) return;
      ModernSnackbar.show(
        context,
        'Lien indisponible pour le moment.',
        success: false,
      );
      return;
    }
    bool ok = false;
    try {
      ok = await launchUrl(
        Uri.parse(target),
        mode: LaunchMode.inAppBrowserView,
      );
    } catch (_) {}
    if (!ok) {
      try {
        ok = await launchUrl(
          Uri.parse(target),
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {}
    }
    if (!ok && mounted) {
      ModernSnackbar.show(
        context,
        'Impossible d’ouvrir le lien pour le moment.',
        success: false,
      );
    }
  }

  Future<void> openSupport() async {
    final launched = await handoff.openSupport();
    if (launched) return;
    await openExternal(supportUrl, '');
  }

  Future<void> openTicketCheckout() async {
    final launched = await handoff.openTicketCheckout();
    if (launched) return;
    if (!mounted) return;
    ModernSnackbar.show(
      context,
      'Ouverture du paiement indisponible pour le moment.',
      success: false,
    );
  }

  void showActivationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TicketActivationSheet(
        repository: TicketRepository(),
        onBuyTicket: openTicketCheckout,
      ),
    );
  }

  Future<void> claimCheckin() async {
    final message = await controller.claimCheckin();
    if (!mounted) return;
    ModernSnackbar.show(context, message);
    controller.track('daily_checkin_claimed');
    controller.refresh().then(applySnapshot);
  }

  Future<void> refreshNow() async {
    final s = await controller.refresh();
    applySnapshot(s);
  }
}
