import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class EncryptedPdfCache {
  static const _marker = 1;
  final _storage = const FlutterSecureStorage();

  Future<void> save(String key, List<int> bytes) async {
    final k = await _aesKey();
    final iv = enc.IV.fromSecureRandom(16);
    final cipher = enc.Encrypter(enc.AES(enc.Key.fromUtf8(k)));
    final body = cipher.encryptBytes(bytes, iv: iv).bytes;
    final out = Uint8List(1 + iv.bytes.length + body.length)
      ..[0] = _marker
      ..setRange(1, 17, iv.bytes)
      ..setRange(17, 17 + body.length, body);
    final f = await _file(key);
    await f.writeAsBytes(out, flush: true);
  }

  Future<List<int>?> read(String key) async {
    final f = await _file(key);
    if (!await f.exists()) return null;
    final k = await _aesKey();
    final cipher = enc.Encrypter(enc.AES(enc.Key.fromUtf8(k)));
    try {
      final raw = await f.readAsBytes();
      if (raw.length > 17 && raw.first == _marker) {
        final iv = enc.IV(raw.sublist(1, 17));
        final body = enc.Encrypted(raw.sublist(17));
        return cipher.decryptBytes(body, iv: iv);
      }
      return _readLegacyBase64(f, cipher);
    } catch (_) {
      return _readLegacyBase64(f, cipher);
    }
  }

  Future<void> delete(String key) async {
    final f = await _file(key);
    if (await f.exists()) await f.delete();
  }

  Future<bool> exists(String key) async {
    final f = await _file(key);
    return f.exists();
  }

  Future<File> _file(String key) async {
    final dir = await getApplicationSupportDirectory();
    final cache = Directory('${dir.path}/pdf_cache');
    if (!await cache.exists()) await cache.create(recursive: true);
    return File('${cache.path}/$key.bin');
  }

  Future<String> _aesKey() async {
    const id = 'pdf_cache_aes_key';
    final e = await _storage.read(key: id);
    if (e != null) return e;
    final key = DateTime.now().microsecondsSinceEpoch
        .toString()
        .padRight(32, '0')
        .substring(0, 32);
    await _storage.write(key: id, value: key);
    return key;
  }

  Future<List<int>?> _readLegacyBase64(File f, enc.Encrypter cipher) async {
    try {
      final iv = enc.IV.fromLength(16);
      final raw = await f.readAsString();
      if (raw.trim().isEmpty) return null;
      final out = cipher.decryptBytes(enc.Encrypted.fromBase64(raw), iv: iv);
      return out;
    } catch (_) {
      return null;
    }
  }
}
