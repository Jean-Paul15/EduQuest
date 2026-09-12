import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../domain/quiz_content_block.dart';
import '../constants.dart';
import 'latex_block_renderer.dart';
import 'image_block_renderer.dart';
import 'code_block_renderer.dart';
import 'table_block_renderer.dart';
import 'audio_block_renderer.dart';
import '../quiz_icons.dart';

/// Rendu universel des Content Blocks (V1: text/callout, V2: LaTeX/image/code/table/audio).
class ContentBlockRenderer extends StatelessWidget {
  const ContentBlockRenderer({
    super.key,
    required this.blocks,
    this.textStyle,
    this.cacheManager,
    this.onImageLoadFailed,
  });
  final List<ContentBlock> blocks;
  final TextStyle? textStyle;
  final CacheManager? cacheManager;
  final ValueChanged<String>? onImageLoadFailed;

  static TextStyle get _tStyle => TextStyle(color: cream900, fontSize: 16, height: 1.5);

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox.shrink();
    final style = textStyle ?? _tStyle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: blocks.map((b) => _render(b, style)).toList(),
    );
  }

  Widget _render(ContentBlock block, TextStyle base) => switch (block) {
    TextBlock(:final value, :final style) => _text(value, style, base),
    CalloutBlock(:final content, :final variant) => _callout(content, variant, base),
    LatexBlock _ => LatexBlockRenderer(block),
    ImageBlock _ => ImageBlockRenderer(
        block,
        cacheManager: cacheManager,
        onLoadFailed: onImageLoadFailed,
      ),
    CodeBlock _ => CodeBlockRenderer(block),
    TableBlock _ => TableBlockRenderer(block),
    AudioBlock _ => AudioBlockRenderer(block),
  };

  Widget _text(String value, TextBlockStyle style, TextStyle base) {
    final w = style == TextBlockStyle.bold || style == TextBlockStyle.boldItalic
        ? FontWeight.w600 : FontWeight.w400;
    final i = style == TextBlockStyle.italic || style == TextBlockStyle.boldItalic;
    final p = base.copyWith(fontWeight: w, fontStyle: i ? FontStyle.italic : FontStyle.normal);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MarkdownBody(
        data: value,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: p,
          strong: p.copyWith(fontWeight: FontWeight.w600),
          em: p.copyWith(fontStyle: FontStyle.italic),
          listBullet: p,
          a: p.copyWith(color: gold500, decoration: TextDecoration.underline),
        ),
      ),
    );
  }

  Widget _callout(List<ContentBlock> content, CalloutVariant v, TextStyle base) {
    final (icon, bg) = switch (v) {
      CalloutVariant.info => (QuizIcons.info, const Color(0xFF1E3A5F)),
      CalloutVariant.warning => (QuizIcons.warning, const Color(0xFF5C3A1E)),
      CalloutVariant.formula => (QuizIcons.functions, const Color(0xFF2A1A3E)),
    };
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cream200)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(right: 10, top: 2),
            child: Icon(icon, size: 18, color: cream700)),
        Expanded(child: ContentBlockRenderer(
          blocks: content,
          textStyle: base,
          cacheManager: cacheManager,
          onImageLoadFailed: onImageLoadFailed,
        )),
      ]));
  }
}
