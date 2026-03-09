import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:luna/core/encryption/encryption_service.dart';
import 'package:luna/features/cycle/data/repositories/cycle_repository_impl.dart';
import 'package:luna/features/cycle/domain/repositories/i_cycle_repository.dart';
import 'package:luna/features/symptoms/data/repositories/symptom_repository_impl.dart';
import 'package:luna/features/symptoms/domain/repositories/i_symptom_repository.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  ),
);

final encryptionServiceProvider = Provider<EncryptionService>(
  (ref) => EncryptionService(ref.read(flutterSecureStorageProvider)),
);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final cycleRepositoryProvider = Provider<ICycleRepository>(
  (ref) => CycleRepositoryImpl(ref.read(appDatabaseProvider)),
);

final symptomRepositoryProvider = Provider<ISymptomRepository>(
  (ref) => SymptomRepositoryImpl(ref.read(appDatabaseProvider)),
);
