import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:uuid/uuid.dart';

final class StartupAction extends Action<NoPayload, String> {
  const StartupAction({
    super.payload = const NoPayload(),
  }) : super(
         endpoint: '/UserAccess/initialization',
         responseDataFunc: _responseDataFunc,
       );

  static String _responseDataFunc(dynamic response) {
    return 'Login successful';
  }
}

final startUpEvent = ExecuteProcessEvent(
  id: Uuid().v4(),
  action: StartupAction(),
);
