import 'package:bigpay/data/models/response/response.md.dart';

class GeneralResponseConst {
  GeneralResponseConst._();

  static const offline = DataError(
    code: 'unavailable_network',
    status: 'error',
    message:
        'You’re currently offline. Please turn on mobile data or Wi-Fi and try again.',
  );

  static const unknown = DataError(
    code: 'UNKNOWN',
    status: 'error',
    message:
        'We couldn\'t process your request at this time. Please attempt it again',
  );

  static const timeout = DataError(
    code: 'TIMEOUT',
    status: 'error',
    message:
        'This is taking longer than expected. Please check your connection and try again',
  );

  static const forceUpdate = DataError(
    code: '9000',
    status: 'error',
    message:
        'A new version is available. Please update to the latest version to continue using the app',
  );

  static const locationDenied = DataError(
    code: 'LOCATION_DENIED',
    status: 'FAILED',
    message: 'We current do not have permission to your device',
  );

  static const locationDisabled = DataError(
    code: 'LOCATION_DISABLED',
    status: 'FAILED',
    message: 'You have disabled GPS Location on your device',
  );
}
