extension DateTimeExt on DateTime {
  DateTime get dateOnly => DateTime(year, month, day).toUtc();
}
