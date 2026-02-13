import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
        appBar: AppBar(title: Text(widget.title)),
        body: EmptyState(title: 'Lien invalide', subtitle: widget.emptyLabel),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: c.reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: WebViewWidget(controller: c),
    );
  }
}
