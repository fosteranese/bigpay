import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/models/actions/action.dart';

final class GetProfilePictureAction extends Action<NoPayload, String> {
  static const path = 'MyAccount/myProfilePicture';
  static ExecuteProcessEvent? event;

  const GetProfilePictureAction({
    required super.payload,
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  static String _responseDataFunc(dynamic data) {
    return data as String;
  }
}
