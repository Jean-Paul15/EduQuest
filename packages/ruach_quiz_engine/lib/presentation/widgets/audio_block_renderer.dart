import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/quiz_content_block.dart';
import '../constants.dart';
import 'audio_action_chip.dart';
import '../quiz_icons.dart';

class AudioBlockRenderer extends StatelessWidget {
  const AudioBlockRenderer(this.block, {super.key});
  final AudioBlock block;

  @override
  Widget build(BuildContext context) {
    final meta = <String>[
      'Audio',
      if (block.durationSeconds != null) '${block.durationSeconds}s',
      if (block.autoPlay) 'Auto',
    ].join(' • ');
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: surfaceStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: gold500.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  QuizIcons.headphones,
                  color: gold500,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  meta,
                  style: TextStyle(
                    color: cream900,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (block.transcript != null) ...[
            const SizedBox(height: 10),
            Text(
              block.transcript!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cream700,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AudioActionChip(
                icon: QuizIcons.copy,
                label: 'Copier le lien',
                onTap: () => _copyLink(context),
              ),
              if (block.transcript != null)
                AudioActionChip(
                  icon: QuizIcons.article,
                  label: 'Transcription',
                  onTap: () => _showTranscript(context),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: block.url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Lien audio copié.')));
  }

  Future<void> _showTranscript(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: ink900,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Transcription',
                  style: TextStyle(
                    color: cream900,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: SelectableText(
                    block.transcript ?? '',
                    style: TextStyle(
                      color: cream700,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
