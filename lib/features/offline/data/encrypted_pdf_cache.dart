import 'dart:io';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class EncryptedPdfCache {
  final _storage = const FlutterSecureStorage();

  Future<void> save(String key, List<int> bytes) async {
    final k = await _aesKey();
    final iv = enc.IV.fromLength(16);
    final cipher = enc.Encrypter(enc.AES(enc.Key.fromUtf8(k)));
    final out = cipher.encryptBytes(bytes, iv: iv).base64;
    final f = await _file(key);
    await f.writeAsString(out, flush: true);
  }

  Future<List<int>?> read(String key) async {
    final f = await _file(key);
    if (!await f.exists()) return null;
    final k = await _aesKey();
    final iv = enc.IV.fromLength(16);
    final cipher = enc.Encrypter(enc.AES(enc.Key.fromUtf8(k)));
    final out = cipher.decryptBytes(enc.Encrypted.fromBase64(await f.readAsString()), iv: iv);
    return out;
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
    final key = DateTime.now().microsecondsSinceEpoch.toString().padRight(32, '0').substring(0, 32);
    await _storage.write(key: id, value: key);
    return key;
  }
}
