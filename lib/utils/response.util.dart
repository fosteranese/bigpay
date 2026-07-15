import 'dart:async';
import 'dart:io';

import 'package:bigpay/constants/response.const.dart';
import 'package:bigpay/constants/status.const.dart';
import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/logger.dart';

class ResponseUtil {
  static String convertFromStatusCode(int code) {
    switch (code) {
      case 1:
        return StatusConstants.success;
      case 0:
      case 2:
      case 100:
        return StatusConstants.failed;
      case 3:
        return StatusConstants.pending;
      case 5:
        return StatusConstants.processing;
      default:
        return StatusConstants.error;
    }
  }

  static int convertToStatusCode(String code) {
    switch (code) {
      case StatusConstants.success:
        return 1;
      case StatusConstants.failed:
        return 2;
      case StatusConstants.pending:
        return 3;
      case StatusConstants.processing:
        return 3;
      default:
        return -1;
    }
  }

  static DataError mapException(Object exception) {
    logger.e(exception);

    if (exception is DataError) return exception;

    // A non-error Response that still describes a failure — reshape it.
    // (DataError is a Response, so this only catches the other subtypes.)
    if (exception is Response) {
      return DataError(
        code: exception.code,
        status: exception.status,
        message: exception.message,
      );
    }

    // No network connection.
    if (exception is SocketException) return GeneralResponseConst.offline;

    // Request timed out.
    if (exception is TimeoutException) return GeneralResponseConst.timeout;

    // Anything else is unexpected.
    return GeneralResponseConst.unknown;
  }
}
