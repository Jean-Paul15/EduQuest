import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:eduquest/shared/deeplink/app_deep_link_command.dart';
import 'package:eduquest/shared/deeplink/app_deep_link_parser.dart';

class AppDeepLinkService {
  final _links = AppLinks();
  StreamSubscription<Uri>? _sub;

  Future<void> start() async {
    _sub ??= _links.uriLinkStream.listen(_onUri, onError: (_) {});
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  void _onUri(Uri uri) {
    final cmd = AppDeepLinkParser.fromUri(uri);
    if (cmd == null) return;
    AppDeepLinkBus.emit(cmd);
  }
}
