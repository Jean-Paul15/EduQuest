/// Content Blocks — langage universel de contenu du moteur.
/// V1 : types `text` et `callout` — V2 : LaTeX, image, code, table, audio.
sealed class ContentBlock {
  const ContentBlock();
}

class TextBlock extends ContentBlock {
  const TextBlock(this.value, {this.style = TextBlockStyle.normal});
  final String value;
  final TextBlockStyle style;
}

class CalloutBlock extends ContentBlock {
  const CalloutBlock({required this.content, this.variant = CalloutVariant.info});
  final List<ContentBlock> content;
  final CalloutVariant variant;
}

class LatexBlock extends ContentBlock {
  const LatexBlock({required this.formula, required this.semanticLabel,
    this.display = false});
  final String formula;
  final String semanticLabel;
  final bool display;
}

class ImageBlock extends ContentBlock {
  const ImageBlock({required this.url, required this.alt, this.caption,
    this.widthPercent = 100, this.aspectRatio});
  final String url;
  final String alt;
  final String? caption;
  final double widthPercent;
  final double? aspectRatio;
}

class CodeBlock extends ContentBlock {
  const CodeBlock({required this.language, required this.value,
    this.lineNumbers = true});
  final String language;
  final String value;
  final bool lineNumbers;
}

class TableBlock extends ContentBlock {
  const TableBlock({required this.headers, required this.rows, this.caption});
  final List<ContentBlock> headers;
  final List<List<ContentBlock>> rows;
  final String? caption;
}

class AudioBlock extends ContentBlock {
  const AudioBlock({required this.url, this.durationSeconds,
    this.transcript, this.autoPlay = false});
  final String url;
  final int? durationSeconds;
  final String? transcript;
  final bool autoPlay;
}

enum TextBlockStyle { normal, bold, italic, boldItalic }

enum CalloutVariant { info, warning, formula }

enum FeedbackMode { immediate, afterSubmit, never }

/// Content types badge labels — computed from blocks present in quiz.
enum ContentTypeBadge { latex, image, code, audio, interactive }

String contentTypeBadgeLabel(ContentTypeBadge b) => switch (b) {
  ContentTypeBadge.latex => '\u{2211} Formules',
  ContentTypeBadge.image => '\u{2B1C} Images',
  ContentTypeBadge.code => '\u{2328} Code',
  ContentTypeBadge.audio => '\u{266A} Audio',
  ContentTypeBadge.interactive => '\u{2726} Interactif',
};
