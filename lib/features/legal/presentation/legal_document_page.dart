import 'package:eduquest/features/legal/data/legal_repository.dart';
import 'package:eduquest/features/legal/domain/legal_document.dart';
import 'package:eduquest/features/legal/presentation/widgets/legal_consent_action.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class LegalDocumentPage extends StatefulWidget {
  const LegalDocumentPage({
    super.key,
    required this.docType,
    this.showAcceptAction = true,
  });
  final String docType;
  final bool showAcceptAction;
  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

class _LegalDocumentPageState extends State<LegalDocumentPage> {
  final _repo = LegalRepository();
  LegalDocument? _doc;
  ({String version, DateTime acceptedAt})? _accepted;
  bool _accepting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _repo.load(widget.docType),
      _repo.latestAccepted(widget.docType),
    ]);
    if (!mounted) return;
    setState(() {
      _doc = results[0] as LegalDocument;
      _accepted = results[1] as ({String version, DateTime acceptedAt})?;
    });
  }

  Future<void> _accept() async {
    final d = _doc;
    if (d == null || _accepting) return;
    setState(() => _accepting = true);
    try {
      await _repo.accept(d);
      if (!mounted) return;
      setState(() => _accepted = (version: d.version, acceptedAt: DateTime.now()));
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _doc;
    return Scaffold(
      appBar: RuachAppBar(title: d?.title ?? 'Document légal', showBack: true),
      body: d == null
          ? const Center(child: RuachLoader(label: 'Chargement du document'))
          : ListView(
              padding: const EdgeInsets.all(RuachSpace.s4),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RuachSpace.s3,
                    vertical: RuachSpace.s2,
                  ),
                  decoration: BoxDecoration(
                    color: RuachColors.gold500.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(RuachRadius.sm),
                  ),
                  child: Text(
                    'Version: ${d.version}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: RuachColors.gold500,
                    ),
                  ),
                ),
                const SizedBox(height: RuachSpace.s4),
                MarkdownBody(data: d.body, selectable: true),
                if (widget.showAcceptAction) ...[
                  const SizedBox(height: RuachSpace.s6),
                  LegalConsentAction(
                    currentVersion: d.version,
                    acceptedVersion: _accepted?.version,
                    acceptedAt: _accepted?.acceptedAt,
                    accepting: _accepting,
                    onAccept: _accept,
                  ),
                ],
              ],
            ),
    );
  }
}
