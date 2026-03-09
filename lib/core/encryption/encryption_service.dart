import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:luna/core/constants/app_constants.dart';

/// AES-256-GCM. Key is stored in Keychain / Android Keystore.
class EncryptionService {
  EncryptionService(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  Key? _key;

  Future<void> init() async {
    final stored = await _secureStorage.read(
      key: AppConstants.encryptionKeyStorageKey,
    );

    if (stored != null) {
      _key = Key(base64Decode(stored));
    } else {
      final newKey = Key.fromSecureRandom(32);
      await _secureStorage.write(
        key: AppConstants.encryptionKeyStorageKey,
        value: base64Encode(newKey.bytes),
      );
      _key = newKey;
    }
  }

  /// Returns base64(iv + ciphertext).
  String encrypt(String plaintext) {
    _assertInitialized();
    final iv = IV.fromSecureRandom(12); // GCM requires a 96-bit IV
    final encrypter = Encrypter(AES(_key!, mode: AESMode.gcm));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    final combined = Uint8List(12 + encrypted.bytes.length)
      ..setRange(0, 12, iv.bytes)
      ..setRange(12, 12 + encrypted.bytes.length, encrypted.bytes);
    return base64Encode(combined);
  }

  /// Accepts base64(iv + ciphertext).
  String decrypt(String ciphertext) {
    _assertInitialized();
    final combined = base64Decode(ciphertext);
    final iv = IV(Uint8List.fromList(combined.sublist(0, 12)));
    final encryptedBytes = Encrypted(Uint8List.fromList(combined.sublist(12)));
    final encrypter = Encrypter(AES(_key!, mode: AESMode.gcm));
    return encrypter.decrypt(encryptedBytes, iv: iv);
  }

  /// For backup: returns bytes(iv + ciphertext).
  Uint8List encryptBytes(Uint8List plainBytes) {
    _assertInitialized();
    final iv = IV.fromSecureRandom(12);
    final encrypter = Encrypter(AES(_key!, mode: AESMode.gcm));
    final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);
    return Uint8List(12 + encrypted.bytes.length)
      ..setRange(0, 12, iv.bytes)
      ..setRange(12, 12 + encrypted.bytes.length, encrypted.bytes);
  }

  /// For backup: accepts bytes(iv + ciphertext).
  Uint8List decryptBytes(Uint8List combined) {
    _assertInitialized();
    final iv = IV(Uint8List.fromList(combined.sublist(0, 12)));
    final encryptedBytes = Encrypted(Uint8List.fromList(combined.sublist(12)));
    final encrypter = Encrypter(AES(_key!, mode: AESMode.gcm));
    return Uint8List.fromList(encrypter.decryptBytes(encryptedBytes, iv: iv));
  }

  bool get isInitialized => _key != null;

  void _assertInitialized() {
    if (_key == null) {
      throw StateError(
        'EncryptionService is not initialized. Call init() before use.',
      );
    }
  }
}
