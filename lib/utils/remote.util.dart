import 'package:bigpay/constants/status.const.dart';
import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/data/remote/main.remote.dart';
import 'package:bigpay/models/actions/action.dart';

class RemoteUtil {
  RemoteUtil._();
  static final remote = MainRemote();

  /// Makes the call and returns the raw envelope — `data` is the decoded JSON,
  /// not the action's typed result.
  ///
  /// Parsing via `Action.responseDataFunc` is deferred to emit time in
  /// [ProcessBloc], so a response can be cached as plain JSON and re-parsed on
  /// read. Parsing here instead would put non-serializable typed objects into
  /// the cache, which then fails to persist.
  static Future<DataResponse<dynamic>> makeCall(Action action) async {
    final response = await remote.post(
      path: action.endpoint,
      body: action.payload.toMap(),
      isAuthenticated: action.isAuthenticated,
    );

    if (response.status != StatusConstants.success) {
      return Future.error(
        DataError(
          code: response.code,
          status: response.status,
          message: response.message,
        ),
      );
    }

    return DataResponse<dynamic>(
      code: response.code,
      status: response.status,
      message: response.message,
      data: response.data,
      imageBaseUrl: response.imageBaseUrl,
      imageDirectory: response.imageDirectory,
      timeStamp: response.timeStamp,
    );
  }
}
