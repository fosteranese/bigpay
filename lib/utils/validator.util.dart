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

  static bool ghanaPhoneLoose(String value) {
    var regex = RegExp(r'^0[0-9]{9}$');
    return regex.firstMatch(value) != null;
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

  static String? Function(String?) phoneValidator(String message) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return null;
      if (!ghanaPhoneLoose(value.trim())) return message;
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
