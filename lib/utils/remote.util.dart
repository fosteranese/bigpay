import 'package:bigpay/constants/status.const.dart';
import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/data/remote/main.remote.dart';
import 'package:bigpay/models/actions/action.dart';

class RemoteUtil {
  RemoteUtil._();
  static final remote = MainRemote();

  static Future<DataResponse<T1>>
  makeCall<T extends ActionPayloadSerializable, T1>(
    Action<T, T1> action,
  ) async {
    final response = await remote.post(
      path: action.endpoint,
      body: action.payload.toMap(),
    );

    if (response.code != StatusConstants.success) {
      return Future.error(
        DataError(
          code: response.code,
          status: response.status,
          message: response.message,
        ),
      );
    }

    final parse = action.responseDataFunc;
    final T1 data = parse != null ? parse(response.data) : response.data as T1;

    return DataResponse<T1>(
      code: response.code,
      status: response.status,
      message: response.message,
      data: data,

      imageBaseUrl: response.imageBaseUrl,
      imageDirectory: response.imageDirectory,
      timeStamp: response.timeStamp,
    );
  }
}
