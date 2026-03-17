extension DateTimeExt on DateTime {
  /// Strips time components and converts to UTC midnight.
  DateTime get dateOnly => DateTime(year, month, day).toUtc();
}
