/// Midnight-normalised dates.
///
/// Cycle maths compares days, never instants. Four call sites had each spelled
/// this out as their own private helper.
extension DateOnly on DateTime {
  /// This date at midnight, local time.
  DateTime get dateOnly => DateTime(year, month, day);

  /// The last representable instant of this date, for an inclusive range end.
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
}
