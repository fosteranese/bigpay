class Validator {
  Validator._();

  static bool ghanaPhoneNumber(String phoneNumber) {
    var regex = RegExp(
      r'^0{1}[0-9]{2}\s{1}[0-9]{3}\s{1}[0-9]{4}$',
    );
    return regex.firstMatch(phoneNumber) != null;
  }

  static bool ghanaCard(String identificationNumber) {
    var regex = RegExp(r'^[A-Za-z]{3}-[0-9]{9}-[0-9]{1}$');
    return regex.firstMatch(identificationNumber) != null;
  }

  static bool email(String value) {
    var regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.firstMatch(value) != null;
  }

  /// Ghana mobile check — strips separators and accepts a national number
  /// (10 digits, leading `0`) or an international one (12 digits, leading
  /// `233`).
  static bool phone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return digits.startsWith('0');
    if (digits.length == 12) return digits.startsWith('233');
    return false;
  }

  static String? Function(String?) requiredField(String message) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return message;
      return null;
    };
  }

  static String? Function(String?) emailValidator(String message) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return null;
      if (!email(value.trim())) return message;
      return null;
    };
  }

  static String? Function(String?) maxLengthValidator(
    int max,
    String message,
  ) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return null;
      if (value.trim().length > max) return message;
      return null;
    };
  }
}
