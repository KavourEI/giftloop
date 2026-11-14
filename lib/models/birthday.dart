/// A birthday whose year may be unknown.
///
/// Stored as `YYYY-MM-DD` when the year is known, or `--MM-DD` (the ISO 8601 /
/// vCard form for a date without a year) when it is not. Contacts often hold
/// birthdays without a year, and many people know a friend's birthday but not
/// their age.
class Birthday {
  final int? year;
  final int month;
  final int day;

  const Birthday({this.year, required this.month, required this.day});

  static Birthday? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      if (raw.startsWith('--')) {
        final parts = raw.substring(2).split('-');
        return Birthday(month: int.parse(parts[0]), day: int.parse(parts[1]));
      }
      final d = DateTime.parse(raw);
      return Birthday(year: d.year, month: d.month, day: d.day);
    } catch (_) {
      return null;
    }
  }

  String encode() {
    final mm = month.toString().padLeft(2, '0');
    final dd = day.toString().padLeft(2, '0');
    if (year == null) return '--$mm-$dd';
    return '${year.toString().padLeft(4, '0')}-$mm-$dd';
  }

  /// The date this birthday falls on in [y]. A 29 February birthday is
  /// observed on 28 February in years that are not leap years.
  DateTime inYear(int y) {
    if (month == 2 && day == 29 && !_isLeap(y)) return DateTime(y, 2, 28);
    return DateTime(y, month, day);
  }

  /// The next occurrence on or after [from] (date only).
  DateTime nextOccurrence([DateTime? from]) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisYear = inYear(today.year);
    return thisYear.isBefore(today) ? inYear(today.year + 1) : thisYear;
  }

  int daysUntil([DateTime? from]) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Calendar-day difference computed in UTC so DST shifts cannot make a day
    // 23 hours long and round the count down.
    final next = nextOccurrence(now);
    return DateTime.utc(next.year, next.month, next.day)
        .difference(DateTime.utc(today.year, today.month, today.day))
        .inDays;
  }

  /// The age the person turns on their next birthday, if the year is known.
  int? get turningAge {
    if (year == null) return null;
    final age = nextOccurrence().year - year!;
    return age > 0 ? age : null;
  }

  /// A DateTime for display/formatting. Uses a leap year when the year is
  /// unknown so 29 February stays valid.
  DateTime get displayDate => DateTime(year ?? 2000, month, day);

  static bool _isLeap(int y) => (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;
}
