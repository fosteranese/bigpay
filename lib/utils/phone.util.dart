/// Phone-number helpers.
extension PhoneFormat on String {
  /// Converts a 233-prefixed MSISDN (e.g. `233244123456`) to the local
  /// 0-prefixed form (`0244123456`), replacing only the **leading** country
  /// code — not every `233` in the number, which `replaceAll` would.
  String get toLocalPhone =>
      startsWith('233') ? '0${substring(3)}' : this;
}
