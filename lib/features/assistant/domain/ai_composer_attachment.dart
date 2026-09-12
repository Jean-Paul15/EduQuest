import 'dart:typed_data';

class AiComposerAttachment {
  const AiComposerAttachment({
    required this.bytes,
    required this.mimeType,
    this.fileName,
  });

  final Uint8List bytes;
  final String mimeType;
  final String? fileName;
}
