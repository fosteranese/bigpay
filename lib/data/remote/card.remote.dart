import 'package:bigpay/constants/status.const.dart';
import 'package:bigpay/data/remote/main.remote.dart';

/// Thrown when the card (3-D Secure) backend returns a non-success status.
class CardRemoteException implements Exception {
  CardRemoteException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Result of `api/card/initiate` — the 3DS setup data.
class CardInitiateResult {
  const CardInitiateResult({
    required this.id,
    required this.deviceDataCollectionUrl,
    required this.accessToken,
  });

  final String id;
  final String deviceDataCollectionUrl;
  final String accessToken;

  factory CardInitiateResult.fromJson(Map<String, dynamic> json) =>
      CardInitiateResult(
        id: json['id'] as String? ?? '',
        deviceDataCollectionUrl:
            json['deviceDataCollectionUrl'] as String? ?? '',
        accessToken: json['accessToken'] as String? ?? '',
      );
}

/// Result of `api/card/enroll` — either frictionless completion or a challenge.
class CardEnrollResult {
  const CardEnrollResult({
    required this.completed,
    this.stepUpUrl,
    this.accessToken,
    this.result,
  });

  final bool completed;
  final String? stepUpUrl;
  final String? accessToken;
  final CardLinkResult? result;

  factory CardEnrollResult.fromJson(Map<String, dynamic> json) =>
      CardEnrollResult(
        completed: json['completed'] as bool? ?? false,
        stepUpUrl: json['stepUpUrl'] as String?,
        accessToken: json['accessToken'] as String?,
        result: json['result'] == null
            ? null
            : CardLinkResult.fromJson(json['result'] as Map<String, dynamic>),
      );
}

/// The final card-linking outcome.
class CardLinkResult {
  const CardLinkResult({
    required this.status,
    required this.cardLinked,
    required this.message,
  });

  final String status;
  final bool cardLinked;
  final String message;

  factory CardLinkResult.fromJson(Map<String, dynamic> json) => CardLinkResult(
    status: json['status'] as String? ?? '',
    cardLinked: json['cardLinked'] as bool? ?? false,
    message: json['message'] as String? ?? '',
  );
}

/// The "browser" (webview) fields the EMV 3-D Secure directory server expects
/// on the check-enrollment request. Collected on-device and passed through.
class CardBrowser {
  const CardBrowser({
    required this.browserLanguage,
    required this.browserScreenWidth,
    required this.browserScreenHeight,
    this.browserColorDepth = '24',
    this.browserTimeZone = '0',
    this.browserJavaEnabled = false,
    this.browserJavaScriptEnabled = true,
    required this.browserUserAgent,
    required this.browserAcceptHeader,
  });

  final String browserLanguage;
  final int browserScreenWidth;
  final int browserScreenHeight;
  final String browserColorDepth;
  final String browserTimeZone;
  final bool browserJavaEnabled;
  final bool browserJavaScriptEnabled;
  final String browserUserAgent;
  final String browserAcceptHeader;

  Map<String, dynamic> toJson() => {
    'browserLanguage': browserLanguage,
    'browserScreenWidth': browserScreenWidth,
    'browserScreenHeight': browserScreenHeight,
    'browserColorDepth': browserColorDepth,
    'browserTimeZone': browserTimeZone,
    'browserJavaEnabled': browserJavaEnabled,
    'browserJavaScriptEnabled': browserJavaScriptEnabled,
    'browserUserAgent': browserUserAgent,
    'browserAcceptHeader': browserAcceptHeader,
  };
}

/// 3-D Secure card client, served by the main BigPay backend.
///
/// The card endpoints were folded into the main backend under the
/// `/AddCard/...` routes, so they ride the same [MainRemote] encryption
/// envelope (RSA/AES + SSL pinning) as every other API call instead of the
/// old plain-JSON service.
class CardRemote {
  CardRemote._();

  static final MainRemote _remote = MainRemote();

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _remote.post(
      path: path,
      body: body,
      isAuthenticated: true,
    );

    if (response.status != StatusConstants.success) {
      final message = response.message.trim();
      throw CardRemoteException(
        message.isEmpty || message == 'null' ? 'Request failed' : message,
      );
    }

    return (response.data as Map<String, dynamic>?) ?? const {};
  }

  static Future<CardInitiateResult> initiate({
    required String cardNumber,
    required String expiry,
    required String cvv,
  }) async {
    final data = await _post('AddCard/initiate', {
      'cardNumber': cardNumber,
      'expiry': expiry,
      'cvv': cvv,
    });
    return CardInitiateResult.fromJson(data);
  }

  static Future<CardEnrollResult> enroll(String id, {CardBrowser? browser}) async {
    final data = await _post('AddCard/enroll', {
      'id': id,
      if (browser != null) 'browser': browser.toJson(),
    });
    return CardEnrollResult.fromJson(data);
  }

  static Future<CardLinkResult> status(String id) async {
    final data = await _post('AddCard/status', {'id': id});
    return CardLinkResult.fromJson(data);
  }
}
