import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/status.const.dart';
import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/models/actions/action.dart';

final class LogoutAction extends Action<NoPayload, Null> {
  static const path = '/UserAccess/Logout';
  static ExecuteProcessEvent? event;

  const LogoutAction({
    required super.payload,
  }) : super(
         endpoint: path,
         noRemoteFunc: _noRemoteFunc,
       );

  static DataResponse<Null> _noRemoteFunc(dynamic response) {
    return DataResponse<Null>(
      code: StatusCodeConstants.success,
      status: StatusConstants.success,
      message: 'logged out',
      data: null,
    );
  }
}
