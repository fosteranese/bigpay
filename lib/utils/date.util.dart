class DateUtil {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// A short, chat-style rendering of [input]: a bare time for something
  /// from today ("3:45 PM"), "Yesterday", a weekday name within the last
  /// week, or a short date beyond that (with the year only if it isn't this
  /// one) — the same idea every chat/inbox app uses so a timestamp doesn't
  /// crowd out the content next to it. Falls back to [format] if [input]
  /// isn't parseable as a real date/time (unlike [format], this needs an
  /// actual `DateTime` to compare against now).
  static String relative(String? input) {
    if (input == null || input.isEmpty) return '';
    final date = DateTime.tryParse(input);
    if (date == null) return format(input);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(date.year, date.month, date.day);
    final dayDiff = today.difference(that).inDays;

    if (dayDiff == 0) return _timeOf(date);
    if (dayDiff == 1) return 'Yesterday';
    if (dayDiff > 1 && dayDiff < 7) return _weekdays[date.weekday - 1];

    final year = date.year == now.year ? '' : ' ${date.year}';
    return '${date.day} ${_months[date.month - 1]}$year';
  }

  /// Just the time portion of [input] ("3:45 PM"), whatever day it falls
  /// on — for a per-message stamp sitting under a [dayLabel] divider that
  /// already says which day it is, so unlike [relative] this always shows a
  /// time instead of falling back to just the day name once it isn't today.
  static String time(String? input) {
    if (input == null || input.isEmpty) return '';
    final date = DateTime.tryParse(input);
    if (date == null) return format(input);
    return _timeOf(date);
  }

  /// Formats a [DateTime]'s own hour/minute directly ("3:45 PM", "12:05 AM")
  /// — not by restringing them and handing that to [_fmtTime], which parses
  /// a fixed-width "HH:MM" shape sliced out of a raw ISO string and breaks
  /// on a single-digit hour or minute (`'${date.hour}:${date.minute}'` for
  /// 9:05 is `"9:5"`, too short for its assumed offsets — silently caught,
  /// so this produced an empty string instead of an obvious crash).
  static String _timeOf(DateTime date) {
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final hour12 = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    return '$hour12:${date.minute.toString().padLeft(2, '0')} $period';
  }

  /// A day-level label for a date-separator between messages sent on
  /// different days — "Today", "Yesterday", a weekday name within the last
  /// week, or a short date beyond that (with the year only if it isn't this
  /// one). Unlike [relative], this never includes a time — it's for a
  /// divider that groups a whole day's messages, not one timestamp.
  static String dayLabel(String? input) {
    if (input == null || input.isEmpty) return '';
    final date = DateTime.tryParse(input);
    if (date == null) return format(input);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(date.year, date.month, date.day);
    final dayDiff = today.difference(that).inDays;

    if (dayDiff == 0) return 'Today';
    if (dayDiff == 1) return 'Yesterday';
    if (dayDiff > 1 && dayDiff < 7) return _weekdays[date.weekday - 1];

    final year = date.year == now.year ? '' : ' ${date.year}';
    return '${date.day} ${_months[date.month - 1]}$year';
  }

  /// True when [a] and [b] fall on the same calendar day. False (not just
  /// "unknown") when either fails to parse, so an unparseable date never
  /// silently merges into whatever group came before it.
  static bool isSameDay(String? a, String? b) {
    if (a == null || b == null) return false;
    final da = DateTime.tryParse(a);
    final db = DateTime.tryParse(b);
    if (da == null || db == null) return false;
    return da.year == db.year && da.month == db.month && da.day == db.day;
  }

  /// Formats a date string [input] into "12 Jan 2024, 3:45 PM".
  /// Supports ISO 8601 (yyyy-MM-dd, yyyy-MM-ddTHH:mm:ss) and dd/MM/yyyy.
  static String format(String? input) {
    if (input == null || input.isEmpty) return '';
    return _tryParse(input) ?? input;
  }

  static String? _tryParse(String s) {
    try {
      final hasTime = s.contains('T');
      final parts = hasTime ? s.split('T') : [s];
      final datePart = parts.first;
      final timePart = hasTime && parts.length > 1 ? parts.last : null;

      final dash = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
      var m = dash.firstMatch(datePart);
      if (m != null) {
        return _fmt(
          int.parse(m[1]!),
          int.parse(m[2]!),
          int.parse(m[3]!),
          timePart,
        );
      }

      final slash = RegExp(r'^(\d{2})[/\-](\d{2})[/\-](\d{4})$');
      m = slash.firstMatch(datePart);
      if (m != null) {
        return _fmt(
          int.parse(m[3]!),
          int.parse(m[2]!),
          int.parse(m[1]!),
          timePart,
        );
      }
    } catch (_) {}
    return null;
  }

  static String _fmt(int year, int month, int day, String? time) {
    final date = (month >= 1 && month <= 12)
        ? '$day ${_months[month - 1]} $year'
        : '$year-$month-$day';
    if (time == null || time.isEmpty) return date;
    final t = _fmtTime(time);
    return t != null ? '$date, $t' : date;
  }

  static String? _fmtTime(String raw) {
    try {
      final colon = raw.indexOf(':');
      if (colon < 0) return null;
      final h = int.parse(raw.substring(0, colon));
      final m = int.parse(raw.substring(colon + 1, colon + 3));
      final period = h >= 12 ? 'PM' : 'AM';
      final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$hour12:${m.toString().padLeft(2, '0')} $period';
    } catch (_) {}
    return null;
  }
}
