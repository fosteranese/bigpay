class Validator {
  Validator._();

  static bool ghanaPhoneNumber(String phoneNumber) {
    var regex = RegExp(
      r'^0{1}[0-9]{2}\s{1}[0-9]{3}\s{1}[0-9]{4}$',
    );
    return regex.firstMatch(phoneNumber) != null;
  }

  static bool ghanaCard(String identificationNumber) {
    var regex = RegExp(r'^[0-9]{9}-{1}[0-9]{1}$');
    return regex.firstMatch(identificationNumber) != null;
  }
}
