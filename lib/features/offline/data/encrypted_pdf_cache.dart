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
    try {
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
    } catch (_) {
      // Stockage sécurisé indisponible, clé illisible, dossier inaccessible :
      // le cache est traité comme absent, l'appelant retombe sur le réseau.
      return null;
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

  /// Clés (`resourceId-version`) des fichiers `.bin` présents sur le disque et
  /// dont le nom commence par [prefix]. Sert de repli quand le pointeur de
  /// version est perdu : les octets chiffrés sur disque font foi.
  Future<List<String>> keysWithPrefix(String prefix) async {
    try {
      final dir = await _cacheDir();
      if (!await dir.exists()) return const [];
      final out = <String>[];
      await for (final e in dir.list()) {
        if (e is! File || !e.path.endsWith('.bin')) continue;
        final name = e.uri.pathSegments.last;
        final key = name.substring(0, name.length - 4);
        if (key.startsWith(prefix)) out.add(key);
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  Future<Directory> _cacheDir() async {
    final dir = await getApplicationSupportDirectory();
    return Directory('${dir.path}/pdf_cache');
  }

  Future<File> _file(String key) async {
    final cache = await _cacheDir();
    if (!await cache.exists()) await cache.create(recursive: true);
    return File('${cache.path}/$key.bin');
  }

  static const _keyId = 'pdf_cache_aes_key';
  static const _keyIdBak = 'pdf_cache_aes_key_bak';
  static bool _validKey(String? k) =>
      k != null && const {16, 24, 32}.contains(k.length);

  /// Clé AES persistée en double (principale + secours). On ne régénère JAMAIS
  /// une clé tant qu'une des deux copies est lisible : une lecture ratée
  /// transitoire du secure storage (course au démarrage Android) rendrait sinon
  /// tout le cache chiffré définitivement illisible. Nouvelle clé uniquement
  /// quand les deux copies manquent après une seconde tentative.
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
