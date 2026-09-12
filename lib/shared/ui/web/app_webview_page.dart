import 'package:eduquest/shared/security/sensitive_scope.dart';
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
  int _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) return;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (mounted) {
              setState(() => _progress = value);
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _progress = 100;
                _error = null;
              });
            }
          },
          onWebResourceError: (err) {
            if (mounted) setState(() => _error = err.description);
          },
        ),
      )
      ..loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) => SensitiveScope(child: _buildBody(context));

  Widget _buildBody(BuildContext context) {
    final c = _controller;
    if (c == null) {
      return Scaffold(
        appBar: RuachAppBar(title: widget.title, showBack: true),
        body: EmptyState(
          title: 'Lien invalide',
          subtitle: widget.emptyLabel,
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: RuachAppBar(
          title: widget.title,
          showBack: true,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _progress = 0;
                });
                c.reload();
              },
              icon: const Icon(PhosphorIconsRegular.arrowsClockwise),
            ),
          ],
        ),
        body: EmptyState(
          title: 'Chargement impossible',
          subtitle: _error!,
          actionLabel: 'Réessayer',
          onAction: () {
            setState(() {
              _error = null;
              _progress = 0;
            });
            c.reload();
          },
        ),
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
      body: Stack(
        children: [
          WebViewWidget(controller: c),
          if (_progress < 100)
            const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}
