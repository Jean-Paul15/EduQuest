import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class EncryptedVideoCache {
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
    final raw = await f.readAsBytes();
    if (raw.length <= 17 || raw.first != _marker) return null;
    final iv = enc.IV(raw.sublist(1, 17));
    final body = enc.Encrypted(raw.sublist(17));
    return cipher.decryptBytes(body, iv: iv);
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
    final dir = await getApplicationDocumentsDirectory();
    final cache = Directory('${dir.path}/video_cache');
    if (!await cache.exists()) await cache.create(recursive: true);
    return File('${cache.path}/$key.vid');
  }

  static const _keyId = 'video_cache_aes_key';
  static const _keyIdBak = 'video_cache_aes_key_bak';
  static bool _validKey(String? k) =>
      k != null && const {16, 24, 32}.contains(k.length);

  /// Clé AES persistée en double. On ne régénère jamais tant qu'une copie est
  /// lisible : une lecture ratée transitoire du secure storage rendrait sinon
  /// toutes les vidéos téléchargées définitivement illisibles.
  Future<String> _aesKey() async {
    var primary = await _safeRead(_keyId);
    if (_validKey(primary)) return primary!;
    final backup = await _safeRead(_keyIdBak);
    if (_validKey(backup)) {
      await _safeWrite(_keyId, backup!);
      return backup;
    }
    await Future<void>.delayed(const Duration(milliseconds: 150));
    primary = await _safeRead(_keyId);
    if (_validKey(primary)) return primary!;
    final fresh = DateTime.now().microsecondsSinceEpoch
        .toString()
        .padRight(32, '0')
        .substring(0, 32);
    await _safeWrite(_keyId, fresh);
    await _safeWrite(_keyIdBak, fresh);
    return fresh;
  }

  Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _safeWrite(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {}
  }
}
