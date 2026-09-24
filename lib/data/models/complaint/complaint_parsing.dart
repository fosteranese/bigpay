/// Pulls a list of JSON objects out of a response `data` payload, whether it
/// arrives as a bare list or as an object wrapping the list under one of
/// [keys]. Kept tolerant because the complaint endpoints' exact envelope shape
/// isn't pinned down.
List<Map<String, dynamic>> complaintMapList(dynamic data, List<String> keys) {
  dynamic value = data;
  if (data is Map) {
    for (final key in keys) {
      if (data[key] is List) {
        value = data[key];
        break;
      }
    }
  }
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}
