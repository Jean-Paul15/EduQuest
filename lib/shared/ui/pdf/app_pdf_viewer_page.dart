import 'package:eduquest/shared/security/sensitive_scope.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';

import 'app_pdf_viewer.dart';

class AppPdfViewerPage extends StatelessWidget {
  const AppPdfViewerPage({
    super.key,
    required this.title,
    required this.url,
    required this.emptyLabel,
  });
  final String title;
  final String url;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return SensitiveScope(
      child: Scaffold(
        appBar: RuachAppBar(title: title, showBack: true),
        body: AppPdfViewer(url: url, emptyLabel: emptyLabel),
      ),
    );
  }
}
