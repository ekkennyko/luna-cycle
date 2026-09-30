import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:luna/core/constants/prefs_keys.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

// File layout: 'LUNA' + format version + salt + iv + AES-256-GCM(json).
// The key is derived from the user's password so the file can be restored on another device.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  static const _magic = [0x4C, 0x55, 0x4E, 0x41];
  static const _formatVersion = 1;
  static const _saltLength = 16;
  static const _ivLength = 12;
  static const _tagLength = 16;
  static const _headerLength = 5 + _saltLength + _ivLength;
  static const _pbkdf2Iterations = 210000;
  static const _prefsKeys = [PrefsKeys.userCycleLength, PrefsKeys.userPeriodLength];

  static bool isBackup(Uint8List bytes) => bytes.length >= _headerLength + _tagLength && listEquals(bytes.sublist(0, 4), _magic) && bytes[4] == _formatVersion;

  Future<Uint8List> create(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode({
      'schemaVersion': _db.schemaVersion,
      'cycleEntries': [for (final e in await _db.select(_db.cycleEntries).get()) e.toJson()],
      'symptoms': [for (final s in await _db.select(_db.symptoms).get()) s.toJson()],
      'symptomLogs': [for (final l in await _db.select(_db.symptomLogs).get()) l.toJson()],
      'pregnancies': [for (final p in await _db.select(_db.pregnancies).get()) p.toJson()],
      'prefs': {
        for (final key in _prefsKeys)
          if (prefs.getInt(key) != null) key: prefs.getInt(key),
      },
    });
    return compute(_encrypt, (utf8.encode(json), password));
  }

  // Replaces all data with the backup contents. Returns false if the password is wrong or the file is damaged.
  Future<bool> restore(Uint8List bytes, String password) async {
    final plain = await compute(_decrypt, (bytes, password));
    if (plain == null) return false;
    final data = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;

    await _db.transaction(() async {
      await _db.delete(_db.symptomLogs).go();
      await _db.delete(_db.cycleEntries).go();
      await _db.delete(_db.pregnancies).go();
      await _db.delete(_db.symptoms).go();
      await _db.batch((b) {
        b.insertAll(_db.symptoms, [for (final j in data['symptoms'] as List) Symptom.fromJson(j as Map<String, dynamic>)]);
        b.insertAll(_db.cycleEntries, [for (final j in data['cycleEntries'] as List) CycleEntry.fromJson(j as Map<String, dynamic>)]);
        b.insertAll(_db.symptomLogs, [for (final j in data['symptomLogs'] as List) SymptomLog.fromJson(j as Map<String, dynamic>)]);
        b.insertAll(_db.pregnancies, [for (final j in data['pregnancies'] as List) Pregnancy.fromJson(j as Map<String, dynamic>)]);
      });
    });

    final prefs = await SharedPreferences.getInstance();
    for (final e in (data['prefs'] as Map<String, dynamic>).entries) {
      await prefs.setInt(e.key, e.value as int);
    }
    return true;
  }

  static Uint8List _encrypt((Uint8List, String) args) {
    final (plain, password) = args;
    final random = Random.secure();
    final salt = Uint8List.fromList(List.generate(_saltLength, (_) => random.nextInt(256)));
    final iv = Uint8List.fromList(List.generate(_ivLength, (_) => random.nextInt(256)));
    final cipher = GCMBlockCipher(AESEngine())..init(true, AEADParameters(KeyParameter(_deriveKey(password, salt)), _tagLength * 8, iv, Uint8List(0)));
    return Uint8List.fromList([..._magic, _formatVersion, ...salt, ...iv, ...cipher.process(plain)]);
  }

  static Uint8List? _decrypt((Uint8List, String) args) {
    final (bytes, password) = args;
    final salt = bytes.sublist(5, 5 + _saltLength);
    final iv = bytes.sublist(5 + _saltLength, _headerLength);
    final cipher = GCMBlockCipher(AESEngine())..init(false, AEADParameters(KeyParameter(_deriveKey(password, salt)), _tagLength * 8, iv, Uint8List(0)));
    try {
      return cipher.process(bytes.sublist(_headerLength));
    } on InvalidCipherTextException {
      return null;
    }
  }

  static Uint8List _deriveKey(String password, Uint8List salt) =>
      (PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))..init(Pbkdf2Parameters(salt, _pbkdf2Iterations, 32))).process(utf8.encode(password));
}
