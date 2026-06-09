import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/shared/external/web_checkout_handoff.dart';
import 'package:eduquest/shared/ui/maps/external_maps_launcher.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';

mixin EventDetailNavActionsMixin<T extends StatefulWidget> on State<T> {
  WebCheckoutHandoff get handoff;
  EngagementDetail? get detail;
  String get eventId;

  Future<void> openShop() async {
    final launched = await handoff.openPayment(kind: 'event', id: eventId);
    if (launched || !mounted) return;
    ModernSnackbar.show(
      context,
      'Le service de paiement est indisponible pour le moment.',
      success: false,
    );
  }

  Future<void> openMeeting() async {
    final url = detail?.meetingUrl;
    if (url == null || url.isEmpty) {
      return ModernSnackbar.show(
        context,
        'Lien de réunion indisponible.',
        success: false,
      );
    }
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> openMaps() async {
    final d = detail;
    if (d == null) return;
    final ok = await ExternalMapsLauncher.open(
      venue: d.venue ?? '',
      lat: d.locationLat,
      lng: d.locationLng,
    );
    if (!mounted || ok) return;
    ModernSnackbar.show(context, 'Impossible d’ouvrir Maps.', success: false);
  }
}
