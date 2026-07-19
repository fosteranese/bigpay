import 'package:uuid/uuid.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/initialization_data/initialization_data.dart';
import 'package:bigpay/models/actions/action.dart';

final class StartupAction extends Action<NoPayload, InitializationData> {
  static const path = '/UserAccess/initialization';

  const StartupAction({
    super.payload = const NoPayload(),
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
         isAuthenticated: false,
       );

  static InitializationData _responseDataFunc(dynamic response) {
    return InitializationData.fromMap(response.data as Map<String, dynamic>);
  }
}

final startUpEvent = ExecuteProcessEvent(
  id: Uuid().v4(),
  action: StartupAction(),
  returnSavedResponse: true,
  saveActionResponse: true,
);
