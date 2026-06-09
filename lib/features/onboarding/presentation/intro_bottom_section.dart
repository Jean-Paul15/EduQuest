import 'package:eduquest/features/legal/presentation/legal_document_page.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';

class IntroBottomSection extends StatelessWidget {
  const IntroBottomSection({
    super.key,
    required this.legalLoading,
    required this.isSubmitting,
    required this.hasNext,
    required this.onContinuePressed,
  });

  final bool legalLoading;
  final bool isSubmitting;
  final bool hasNext;
  final VoidCallback onContinuePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'En continuant, tu acceptes nos conditions.',
          textAlign: TextAlign.center,
          style: TextStyle(color: RuachColors.cream700, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: legalLoading
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const LegalDocumentPage(docType: 'terms'),
                        ),
                      ),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Conditions'),
            ),
            TextButton(
              onPressed: legalLoading
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const LegalDocumentPage(docType: 'privacy'),
                        ),
                      ),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Confidentialite'),
            ),
            if (legalLoading)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: RuachButton(
            label: hasNext ? 'Poursuivre' : 'Commencer',
            onPressed: isSubmitting ? null : onContinuePressed,
            loading: isSubmitting,
          ),
        ),
      ],
    );
  }
}
