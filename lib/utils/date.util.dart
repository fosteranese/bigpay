class DateUtil {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

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
        return _fmt(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!),
            timePart);
      }

      final slash = RegExp(r'^(\d{2})[/\-](\d{2})[/\-](\d{4})$');
      m = slash.firstMatch(datePart);
      if (m != null) {
        return _fmt(int.parse(m[3]!), int.parse(m[2]!), int.parse(m[1]!),
            timePart);
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
