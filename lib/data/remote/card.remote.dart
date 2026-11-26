import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:bigpay/env/env.dart';

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

/// Plain-JSON client for the card add (3-D Secure) backend.
///
/// Unlike [MainRemote], this backend is a simple REST service (no
/// request encryption or session envelope), so it gets its own thin client
/// rather than being forced through the BigPay channel.
class CardRemote {
  CardRemote._();

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('${Env.cardBaseUrl}/api/$path');
    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            // ngrok's free tier serves an interstitial unless this header is
            // present. Harmless for a real host, so only send it when the
            // configured base URL actually points at an ngrok tunnel.
            if (_isNgrok) 'ngrok-skip-browser-warning': 'true',
          },
          body: json.encode(body),
        )
        .timeout(const Duration(seconds: 40));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CardRemoteException(_httpErrorMessage(response));
    }

    Map<String, dynamic> decoded;
    try {
      decoded = json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      // Non-JSON body (proxy interstitial, HTML error page, ...).
      throw CardRemoteException('Unexpected response from the card service');
    }

    final status = decoded['status']?.toString();
    if (status != null && status != 'success') {
      throw CardRemoteException(
        decoded['message']?.toString() ?? 'Request failed',
      );
    }
    return (decoded['data'] as Map<String, dynamic>?) ?? const {};
  }

  /// True when the card backend is reached through an ngrok tunnel.
  static bool get _isNgrok => Env.cardBaseUrl.contains('ngrok');

  /// Extracts a human-readable error from an HTTP failure, preferring a JSON
  /// `message` field when the server returned one.
  static String _httpErrorMessage(http.Response response) {
    try {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final message = decoded['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    } catch (_) {
      // Fall through to the status-code message.
    }
    return 'Request failed (HTTP ${response.statusCode})';
  }

  static Future<CardInitiateResult> initiate({
    required String cardNumber,
    required String expiry,
    required String cvv,
  }) async {
    final data = await _post('card/initiate', {
      'cardNumber': cardNumber,
      'expiry': expiry,
      'cvv': cvv,
    });
    return CardInitiateResult.fromJson(data);
  }

  static Future<CardEnrollResult> enroll(String id, {CardBrowser? browser}) async {
    final data = await _post('card/enroll', {
      'id': id,
      if (browser != null) 'browser': browser.toJson(),
    });
    return CardEnrollResult.fromJson(data);
  }

  static Future<CardLinkResult> status(String id) async {
    final data = await _post('card/status', {'id': id});
    return CardLinkResult.fromJson(data);
  }
}
