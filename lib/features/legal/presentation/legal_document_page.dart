import 'package:eduquest/features/legal/data/legal_repository.dart';
import 'package:eduquest/features/legal/domain/legal_document.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class LegalDocumentPage extends StatefulWidget {
  const LegalDocumentPage({super.key, required this.docType});
  final String docType;
  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

class _LegalDocumentPageState extends State<LegalDocumentPage> {
  final _repo = LegalRepository();
  LegalDocument? _doc;

  @override
  void initState() { super.initState();
    _repo.load(widget.docType).then((v) => mounted ? setState(() => _doc = v) : null);
  }

  @override
  Widget build(BuildContext context) {
    final d = _doc;
    return Scaffold(
      appBar: AppBar(title: Text(d?.title ?? 'Document legal')),
      body: d == null
        ? const Center(child: CircularProgressIndicator())
        : ListView(padding: const EdgeInsets.all(AppSpace.l), children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.s),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(AppRadius.xs)),
              child: Text('Version: ${d.version}', style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
            const SizedBox(height: AppSpace.l),
            MarkdownBody(data: d.body, selectable: true),
            const SizedBox(height: AppSpace.xxl),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () => _repo.accept(d),
              child: const Text("J'ai lu et j'accepte"))),
          ]),
    );
  }
}
