import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/status.const.dart';
import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:bigpay/utils/app_state.util.dart';

part 'auth_action.freezed.dart';
part 'auth_action.g.dart';

final class AuthAction extends Action<AuthActionPayload, AuthData> {
  static const path = '/User/Authenticated';
  static ExecuteProcessEvent? event;

  const AuthAction({
    required super.payload,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
         makeRemoteCall: false,
       );

  static AuthData _responseDataFunc(dynamic response) {
    final authData = (response as AuthActionPayload).authData;
    final result = DataResponse(
      code: StatusCodeConstants.success,
      status: StatusConstants.success,
      message: '',
      data: authData,
    );

    AppState.store.cache.write(path, result, endpoint: path);
    return authData;
  }
}

@freezed
abstract class AuthActionPayload
    with _$AuthActionPayload
    implements ActionPayloadSerializable {
  const factory AuthActionPayload({
    required AuthData authData,
  }) = _AuthActionPayload;

  factory AuthActionPayload.fromJson(Map<String, dynamic> json) =>
      _$AuthActionPayloadFromJson(json);
}
