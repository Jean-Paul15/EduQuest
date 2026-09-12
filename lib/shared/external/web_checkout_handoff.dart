import 'dart:math';
import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WebCheckoutHandoff {
  final _config = AppConfigRepository();

  Future<bool> openPayment({
    required String kind,
    required String id,
  }) async {
    final links = await _config.loadAppLinks();
    final paymentTpl = (links['payment_path'] ?? '/payer?kind={kind}&id={id}')
        .trim();
    final path = paymentTpl
        .replaceAll('{kind}', kind)
        .replaceAll('{id}', id);
    final returnLink = _returnLink(kind: kind, id: id);
    final nextPath = _withQuery(path, {
      'next': returnLink,
      'idempotencyKey': _idempotencyKey(kind, id),
    });
    return _openWithHandoff(
      nextPath: nextPath,
      links: links,
      allowDirectFallback: true,
    );
  }

  Future<bool> openSupport() async {
    final links = await _config.loadAppLinks();
    final raw = (links['support_url'] ?? '').trim();
    final base = (links['site_base_url'] ?? '').trim();
    if (_isExternalSupportLink(raw, base)) return _openUrl(Uri.parse(raw));
    final supportPath = _toRelativePath(links['support_url'] ?? '/support');
    final nextPath = _withQuery(supportPath, {
      'next': _returnLink(kind: 'support', id: 'home'),
    });
    return _openWithHandoff(
      nextPath: nextPath,
      links: links,
      allowDirectFallback: true,
    );
  }

  Future<bool> openTicketCheckout() async {
    final links = await _config.loadAppLinks();
    final checkoutPath = _toRelativePath(
      links['ticket_checkout_path'] ?? '/tickets/checkout',
    );
    final nextPath = _withQuery(checkoutPath, {
      'next': _returnLink(kind: 'ticket', id: 'checkout'),
      'idempotencyKey': _idempotencyKey('ticket', 'checkout'),
    });
    return _openWithHandoff(
      nextPath: nextPath,
      links: links,
      allowDirectFallback: false,
    );
  }

  Future<bool> openPublicEventBuy(String eventId) async {
    final links = await _config.loadAppLinks();
    final tpl = (links['public_event_buy_path'] ??
            '/evenements/acheter?eventId={id}')
        .trim();
    final nextPath = _withQuery(
      tpl.replaceAll('{id}', eventId),
      {'next': _returnLink(kind: 'event', id: eventId)},
    );
    return _openWithHandoff(
      nextPath: nextPath,
      links: links,
      allowDirectFallback: true,
    );
  }

  Future<bool> _openWithHandoff({
    required String nextPath,
    required Map<String, String> links,
    required bool allowDirectFallback,
  }) async {
    final base = (links['site_base_url'] ?? '').trim();
    final handoffTpl =
        (links['handoff_path'] ?? '/auth/handoff?token={token}').trim();
    if (base.isEmpty) {
      debugPrint('[Handoff] site_base_url is empty');
      return false;
    }
    final direct = Uri.parse(_combineBase(base, nextPath));
    try {
      final rpc = await Supabase.instance.client.rpc(
        'create_web_session_handoff',
        params: {'p_next_path': nextPath},
      );
      final data = rpc as Map?;
      final token = data?['token']?.toString() ?? '';
      if (data?['success'] != true || token.isEmpty) {
        debugPrint('[Handoff] RPC failed: ${data?['message'] ?? 'no token'}');
        return allowDirectFallback ? _openUrl(direct) : false;
      }
      final handoff = handoffTpl.replaceAll('{token}', token);
      final uri = Uri.parse(_combineBase(base, handoff));
      final ok = await _openUrl(uri);
      if (ok) return true;
      debugPrint('[Handoff] Could not open handoff URL');
    } catch (e) {
      debugPrint('[Handoff] RPC error: $e');
    }
    return allowDirectFallback ? _openUrl(direct) : false;
  }

  String _withQuery(String path, Map<String, String> values) {
    final uri = Uri.parse(path.startsWith('http://') || path.startsWith('https://')
        ? path
        : (path.startsWith('/') ? path : '/$path'));
    final query = Map<String, String>.from(uri.queryParameters)
      ..addAll(values);
    if (uri.hasScheme) {
      return uri.replace(queryParameters: query).toString();
    }
    return Uri(path: uri.path, queryParameters: query).toString();
  }

  String _toRelativePath(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return '/';
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      final u = Uri.parse(raw);
      final q = u.hasQuery ? '?${u.query}' : '';
      return '${u.path.isEmpty ? '/' : u.path}$q';
    }
    return raw.startsWith('/') ? raw : '/$raw';
  }

  String _combineBase(String base, String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final p = path.startsWith('/') ? path : '/$path';
    return '$b$p';
  }

  bool _isExternalSupportLink(String raw, String base) {
    if (!raw.startsWith('http://') && !raw.startsWith('https://')) return false;
    if (base.isEmpty) return true;
    final support = Uri.tryParse(raw);
    final site = Uri.tryParse(base);
    return support == null || site == null || support.host != site.host;
  }

  Future<bool> _openUrl(Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) return true;
    } catch (e) {
      debugPrint('[Handoff] inAppBrowserView failed: $e');
    }
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return true;
    } catch (e) {
      debugPrint('[Handoff] externalApplication failed: $e');
    }
    return false;
  }

  String _returnLink({required String kind, required String id}) {
    final hub = kind == 'ticket' || kind == 'support' ? 'home' : 'hub';
    return Uri(
      scheme: 'ruachedu',
      host: hub,
      queryParameters: {'tab': hub, 'kind': kind, 'id': id},
    ).toString();
  }

  String _idempotencyKey(String kind, String id) {
    final r = Random.secure().nextInt(1 << 32).toRadixString(16);
    return 'app:$kind:$id:${DateTime.now().millisecondsSinceEpoch}:$r';
  }
}
