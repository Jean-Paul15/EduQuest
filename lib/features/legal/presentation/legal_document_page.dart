import 'package:eduquest/features/legal/data/legal_repository.dart';
import 'package:eduquest/features/legal/domain/legal_document.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
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
      appBar: RuachAppBar(title: d?.title ?? 'Document legal'),
      body: d == null
        ? const Center(child: CircularProgressIndicator())
        : ListView(padding: const EdgeInsets.all(RuachSpace.s4), children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: RuachSpace.s3, vertical: RuachSpace.s2),
              decoration: BoxDecoration(
                color: RuachColors.gold500.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(RuachRadius.sm)),
              child: Text('Version: ${d.version}', style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: RuachColors.gold500)),
            ),
            const SizedBox(height: RuachSpace.s4),
            MarkdownBody(data: d.body, selectable: true),
            const SizedBox(height: RuachSpace.s6),
            SizedBox(width: double.infinity, child: RuachButton(
              label: "J'ai lu et j'accepte",
              onPressed: () => _repo.accept(d)),
            ),
          ]),
    );
  }
}
