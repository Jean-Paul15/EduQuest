import 'package:eduquest/features/assistant/domain/ai_composer_attachment.dart';
import 'package:image_picker/image_picker.dart';

abstract class ImagePickerGateway {
  Future<AiComposerAttachment?> pickFromCamera();
  Future<AiComposerAttachment?> pickFromGallery();
}

class DeviceImagePickerGateway implements ImagePickerGateway {
  final _picker = ImagePicker();

  Future<AiComposerAttachment?> _pick(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 70,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return AiComposerAttachment(
      bytes: bytes,
      mimeType: file.mimeType ?? _guessMime(file.path),
      fileName: file.name,
    );
  }

  String _guessMime(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  @override
  Future<AiComposerAttachment?> pickFromCamera() => _pick(ImageSource.camera);

  @override
  Future<AiComposerAttachment?> pickFromGallery() => _pick(ImageSource.gallery);
}
