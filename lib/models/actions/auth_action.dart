import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/auth_data/auth_data.dart';
import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:bigpay/utils/app_state.util.dart';

final class AuthAction extends Action<AuthActionPayload, AuthData> {
  static const path = '/User/Authenticated';
  static ExecuteProcessEvent? event;

  const AuthAction({
    required super.payload,
  }) : super(
         endpoint: path,
         noRemoteFunc: _noRemoteFunc,
       );

  /// Local process: no network. Receives the payload, caches the already-fetched
  /// response, and returns it as the result.
  static DataResponse<AuthData> _noRemoteFunc(dynamic response) {
    final dataResponse = (response as AuthActionPayload).dataResponse;
    AppState.store.cache.write(path, dataResponse, endpoint: path);
    return dataResponse;
  }
}

/// Local-only payload carrying an already-fetched auth response. It never goes
/// over the wire, so [toJson] is empty — no serialization (and no codegen)
/// needed, which also lets it hold a non-serializable [DataResponse].
final class AuthActionPayload implements ActionPayloadSerializable {
  const AuthActionPayload({required this.dataResponse});

  final DataResponse<AuthData> dataResponse;

  @override
  Map<String, dynamic> toJson() => const {};
}
