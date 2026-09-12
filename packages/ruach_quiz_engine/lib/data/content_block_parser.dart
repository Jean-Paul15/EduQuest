import '../domain/quiz_content_block.dart';

/// Parse les Content Blocks depuis le JSON QDL (V1 + V2).
class ContentBlockParser {
  const ContentBlockParser();

  static List<ContentBlock> parseList(dynamic raw) {
    if (raw is! List || raw.isEmpty) return [];
    return raw.whereType<Map<String, dynamic>>().map(parse).toList();
  }

  static List<ContentBlock> parseFlexibleList(dynamic raw) {
    if (raw is String && raw.trim().isNotEmpty) {
      return [TextBlock(raw.trim())];
    }
    if (raw is Map<String, dynamic>) {
      return [parse(raw)];
    }
    return parseList(raw);
  }

  static ContentBlock parse(Map<String, dynamic> block) {
    final type = block['type'] as String? ?? 'text';
    return switch (type) {
      'callout' => CalloutBlock(
          variant: _calloutVariant(block['variant'] as String?),
          content: parseList(block['content']),
        ),
      'latex_inline' => LatexBlock(
          formula: block['formula'] as String? ?? '',
          semanticLabel: block['semantic_label'] as String? ?? '',
        ),
      'latex_display' => LatexBlock(
          formula: block['formula'] as String? ?? '',
          semanticLabel: block['semantic_label'] as String? ?? '',
          display: true,
        ),
      'image' => ImageBlock(
          url: block['url'] as String? ?? '',
          // §2.3/§8.2.2 : alt obligatoire pour l'accessibilité — un `alt`
          // manquant ne doit jamais faire planter le parseur (§5.2), mais
          // ne doit pas non plus laisser un lecteur d'écran muet.
          alt: (block['alt'] as String?)?.trim().isNotEmpty == true
              ? block['alt'] as String
              : 'Image',
          caption: block['caption'] as String?,
          widthPercent: (block['width_percent'] as num?)?.toDouble() ?? 100,
          aspectRatio: (block['aspect_ratio'] as num?)?.toDouble(),
        ),
      'code' => CodeBlock(
          language: block['language'] as String? ?? 'plaintext',
          value: block['value'] as String? ?? '',
          lineNumbers: block['line_numbers'] as bool? ?? true,
        ),
      'table' => TableBlock(
          headers: parseList(block['headers']),
          rows: (block['rows'] as List?)
              ?.map((r) => parseList(r))
              .toList() ?? [],
          caption: block['caption'] as String?,
        ),
      'audio' => AudioBlock(
          url: block['url'] as String? ?? '',
          durationSeconds: block['duration_seconds'] as int?,
          transcript: block['transcript'] as String?,
          autoPlay: block['auto_play'] as bool? ?? false,
        ),
      _ => TextBlock(block['value'] as String? ?? '',
          style: _textStyle(block['style'] as String?)),
    };
  }

  static TextBlockStyle _textStyle(String? s) => switch (s) {
    'bold' => TextBlockStyle.bold, 'italic' => TextBlockStyle.italic,
    'bold_italic' => TextBlockStyle.boldItalic, _ => TextBlockStyle.normal};

  static CalloutVariant _calloutVariant(String? v) => switch (v) {
    'warning' => CalloutVariant.warning,
    'formula' => CalloutVariant.formula, _ => CalloutVariant.info};
}
