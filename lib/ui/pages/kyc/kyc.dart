import 'package:bigpay/routes/app_router.dart';

class Kyc {
  Kyc._();

  static String ghanaCardNumber = '';
  static String passportPicture = '';
  static PageRouteDefinition? route;
  static void Function()? onSuccess;

  static void clear() {
    ghanaCardNumber = '';
    passportPicture = '';
    route = null;
    onSuccess = null;
  }
}
