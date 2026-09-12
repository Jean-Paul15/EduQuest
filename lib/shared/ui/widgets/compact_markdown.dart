import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class CompactMarkdown extends StatelessWidget {
  const CompactMarkdown({
    super.key,
    required this.data,
    this.selectable = false,
  });

  final String data;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return MarkdownBody(
      data: data,
      selectable: selectable,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet(
        p: text.bodyMedium?.copyWith(height: 1.45),
        h1: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        h2: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        h3: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        listBullet: text.bodyMedium,
        blockSpacing: 10,
        listIndent: 16,
        blockquotePadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        blockquoteDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        code: text.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          fontSize: 13,
          backgroundColor: Colors.transparent,
        ),
        codeblockPadding: const EdgeInsets.all(12),
        codeblockDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        strong: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        tableBorder: TableBorder.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        tableCellsPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
      ),
    );
  }
}
