import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AppWebViewPage extends StatefulWidget {
  const AppWebViewPage({
    super.key,
    required this.title,
    required this.url,
    this.emptyLabel = 'Lien indisponible.',
  });
  final String title;
  final String url;
  final String emptyLabel;

  @override
  State<AppWebViewPage> createState() => _AppWebViewPageState();
}

class _AppWebViewPageState extends State<AppWebViewPage> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) return;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null) {
      return Scaffold(
        appBar: RuachAppBar(title: widget.title, showBack: true),
        body: EmptyState(title: 'Lien invalide', subtitle: widget.emptyLabel),
      );
    }
    return Scaffold(
      appBar: RuachAppBar(
        title: widget.title,
        showBack: true,
        actions: [
          IconButton(
            onPressed: c.reload,
            icon: const Icon(PhosphorIconsRegular.arrowsClockwise),
          ),
        ],
      ),
      body: WebViewWidget(controller: c),
    );
  }
}
