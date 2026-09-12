import 'dart:typed_data';

import 'package:eduquest/features/assistant/data/image_picker_gateway.dart';
import 'package:eduquest/features/assistant/domain/ai_composer_attachment.dart';

class FakeImagePickerGateway implements ImagePickerGateway {
  FakeImagePickerGateway({this.result});

  /// Attachement retourné par le prochain appel — laisser à null pour simuler une annulation.
  AiComposerAttachment? result;

  static final _onePixelPng = Uint8List.fromList(const [
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
    0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137,
  ]);

  AiComposerAttachment get _fallback => AiComposerAttachment(
    bytes: _onePixelPng,
    mimeType: 'image/png',
    fileName: 'test.png',
  );

  @override
  Future<AiComposerAttachment?> pickFromCamera() async => result ?? _fallback;

  @override
  Future<AiComposerAttachment?> pickFromGallery() async => result ?? _fallback;
}
