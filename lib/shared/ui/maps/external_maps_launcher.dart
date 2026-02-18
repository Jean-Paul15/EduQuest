import 'package:url_launcher/url_launcher.dart';

class ExternalMapsLauncher {
  static Future<bool> open({
    required String venue,
    double? lat,
    double? lng,
  }) async {
    final q = Uri.encodeComponent(venue.trim());
    final hasPoint = lat != null && lng != null;
    final targets = <Uri>[
      if (hasPoint) Uri.parse('geo:$lat,$lng?q=$lat,$lng($q)'),
      if (hasPoint) Uri.parse('google.navigation:q=$lat,$lng'),
      if (hasPoint)
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'),
      if (!hasPoint && venue.trim().isNotEmpty)
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$q'),
    ];
    for (final uri in targets) {
      final ok = await canLaunchUrl(uri);
      if (!ok) continue;
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (opened) return true;
    }
    return false;
  }
}
