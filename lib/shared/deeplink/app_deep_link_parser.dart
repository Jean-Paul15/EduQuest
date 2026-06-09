import 'package:eduquest/shared/deeplink/app_deep_link_command.dart';

class AppDeepLinkParser {
  static AppDeepLinkCommand? fromUri(Uri uri) {
    if (uri.scheme.toLowerCase() != 'ruachnova') return null;
    if (uri.host.toLowerCase() == 'login-callback') return null;
    final tab = _tabFromUri(uri);
    final kind = (uri.queryParameters['kind'] ?? '').toLowerCase();
    final entityId = uri.queryParameters['id'] ?? '';
    final message = _paymentMessage(uri);
    if (tab == null && message.isEmpty && kind.isEmpty && entityId.isEmpty) {
      return null;
    }
    return AppDeepLinkCommand(
      tabIndex: tab,
      message: message,
      kind: kind,
      entityId: entityId,
    );
  }

  static AppDeepLinkCommand? fromRaw(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null) return null;
    return fromUri(uri);
  }

  static AppDeepLinkCommand? fromNotificationPayload(
    Map<String, dynamic> payload, {
    String fallbackMessage = '',
  }) {
    final deeplink = payload['deeplink']?.toString().trim() ?? '';
    final fromLink = fromRaw(deeplink);
    if (fromLink != null) {
      return fallbackMessage.isEmpty
          ? fromLink
          : AppDeepLinkCommand(
              tabIndex: fromLink.tabIndex,
              message: fromLink.message.isEmpty
                  ? fallbackMessage
                  : fromLink.message,
              kind: fromLink.kind,
              entityId: fromLink.entityId,
            );
    }
    final tab = _tabFromText(payload['tab']?.toString() ?? '');
    final kind = (payload['kind']?.toString() ?? '').toLowerCase();
    final entityId = payload['id']?.toString() ?? '';
    if (tab == null && kind.isEmpty && entityId.isEmpty) return null;
    return AppDeepLinkCommand(
      tabIndex: tab,
      message: fallbackMessage,
      kind: kind,
      entityId: entityId,
    );
  }

  static int? _tabFromText(String v) {
    switch (v.toLowerCase().trim()) {
      case 'home':
        return 0;
      case 'feed':
        return 1;
      case 'learn':
      case 'learning':
      case 'apprendre':
        return 2;
      case 'hub':
        return 3;
      case 'profile':
        return 4;
      default:
        return null;
    }
  }

  static int? _tabFromUri(Uri uri) {
    final host = uri.host.toLowerCase();
    final path = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    final tab = uri.queryParameters['tab']?.toLowerCase() ?? '';
    return _tabFromText([tab, path, host].firstWhere(
      (value) => value.isNotEmpty,
      orElse: () => '',
    ));
  }

  static String _paymentMessage(Uri uri) {
    if ((uri.queryParameters['payment_status'] ?? '').toLowerCase() != 'ok') {
      return '';
    }
    final kind = (uri.queryParameters['kind'] ?? '').toLowerCase();
    final code = uri.queryParameters['activation_code'] ?? '';
    final pass = uri.queryParameters['pass_code'] ?? '';
    final qr = uri.queryParameters['qr_code'] ?? '';
    if (kind == 'ticket') return code.isEmpty ? 'Paiement valide.' : 'Code: $code';
    if (kind == 'event') return pass.isEmpty ? 'Paiement valide.' : 'Pass: $pass';
    if (kind == 'contest') return qr.isEmpty ? 'Paiement valide.' : 'QR: $qr';
    return 'Paiement valide.';
  }
}
