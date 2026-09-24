import 'package:bigpay/models/actions/action.dart';

final class ChangeProfilePictureAction extends Action<ChangeProfilePictureActionPayload, String> {
  static const path = 'MyAccount/updateProfilePicture';

  const ChangeProfilePictureAction({
    required super.payload,
  }) : super(endpoint: path, responseDataFunc: _responseDataFunc);

  static String _responseDataFunc(dynamic data) => data as String;
}

final class ChangeProfilePictureActionPayload implements ActionPayloadSerializable {
  const ChangeProfilePictureActionPayload({required this.picture});

  /// Base64-encoded image.
  final String picture;

  @override
  Map<String, dynamic> toJson() => {'picture': picture};
}
