import 'package:eduquest/shared/ui/pdf/app_pdf_viewer.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class ExamDetailPage extends StatelessWidget {
  const ExamDetailPage({super.key, required this.title, required this.paperUrl, required this.correctionUrl});
  final String title;
  final String paperUrl;
  final String? correctionUrl;

  @override
  Widget build(BuildContext context) {
    final hasCorr = correctionUrl != null && correctionUrl!.isNotEmpty;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: Text(title), bottom: const TabBar(tabs: [Tab(text: 'Sujet PDF'), Tab(text: 'Correction')])),
        body: TabBarView(children: [
          AppPdfViewer(
            url: paperUrl,
            emptyLabel: 'Le sujet de cet examen n’est pas disponible.',
          ),
          hasCorr
              ? AppPdfViewer(
                  url: correctionUrl!,
                  emptyLabel: 'La correction de cet examen est indisponible.',
                )
              : const EmptyState(title: 'Pas de correction', subtitle: 'La correction n’est pas encore publiée.'),
        ]),
      ),
    );
  }
}
