import 'package:flutter/material.dart';
import '../../domain/quiz_content_block.dart';
import '../constants.dart';

class TableBlockRenderer extends StatelessWidget {
  const TableBlockRenderer(this.block, {super.key});
  final TableBlock block;

  @override
  Widget build(BuildContext context) {
    final width = _columnCount == 0 ? 1 : _columnCount;
    if (width == 0 || block.rows.isEmpty && block.headers.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (block.caption != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                block.caption!,
                style: TextStyle(
                  color: cream700,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: surfaceBase,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: surfaceStroke),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: width * 132),
                child: Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(color: surfaceStroke),
                    verticalInside: BorderSide(color: surfaceStroke),
                  ),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    if (block.headers.isNotEmpty)
                      TableRow(
                        decoration: BoxDecoration(color: surfaceRaised),
                        children: List.generate(
                          width,
                          (index) => _cell(
                            index < block.headers.length
                                ? block.headers[index]
                                : null,
                            isHeader: true,
                          ),
                        ),
                      ),
                    ...block.rows.map(
                      (row) => TableRow(
                        children: List.generate(
                          width,
                          (index) =>
                              _cell(index < row.length ? row[index] : null),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int get _columnCount {
    final rowWidths = block.rows.map((row) => row.length);
    return [
      block.headers.length,
      ...rowWidths,
    ].fold(0, (a, b) => a > b ? a : b);
  }

  Widget _cell(ContentBlock? block, {bool isHeader = false}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Text(
      _labelFor(block),
      style: TextStyle(
        color: cream900,
        fontSize: 13,
        height: 1.35,
        fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
      ),
    ),
  );

  String _labelFor(ContentBlock? block) => switch (block) {
    null => '',
    TextBlock(:final value) => value,
    LatexBlock(:final semanticLabel) => semanticLabel,
    CodeBlock(:final language) => 'Code $language',
    ImageBlock(:final alt) => alt,
    AudioBlock(:final durationSeconds) =>
      durationSeconds == null ? 'Audio' : 'Audio ${durationSeconds}s',
    TableBlock _ => 'Tableau',
    CalloutBlock(:final content) =>
      content.map(_labelFor).where((part) => part.isNotEmpty).join(' '),
  };
}
