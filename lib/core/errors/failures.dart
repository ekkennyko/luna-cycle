sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

final class EncryptionFailure extends Failure {
  const EncryptionFailure(super.message);
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

final class SubscriptionFailure extends Failure {
  const SubscriptionFailure(super.message);
}

final class BackupFailure extends Failure {
  const BackupFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
