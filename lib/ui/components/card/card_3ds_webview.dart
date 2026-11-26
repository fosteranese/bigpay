import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Outcome of the 3DS challenge, mirroring the backend's `postMessage` events.
enum CardChallengeResult { completed, failed, cancelled }

/// Thin abstraction over the webview plugin used for the 3-D Secure add-card
/// flow (Cybersource device data collection + the step-up challenge).
///
/// All `flutter_inappwebview` usage lives in this file, so swapping the
/// underlying plugin later touches only this one place — callers depend on
/// [collectDeviceData] and [showChallenge], not on the plugin API.
class Card3DsWebview {
  Card3DsWebview._();

  /// Runs Cybersource device data collection in a hidden headless webview.
  static Future<void> collectDeviceData({
    required String deviceDataCollectionUrl,
    required String accessToken,
  }) async {
    final completer = Completer<void>();
    final headless = HeadlessInAppWebView(
      initialData: InAppWebViewInitialData(
        data: _ddcHtml(
          deviceDataCollectionUrl: deviceDataCollectionUrl,
          accessToken: accessToken,
        ),
      ),
      onWebViewCreated: (controller) {
        controller.addJavaScriptHandler(
          handlerName: 'ddcComplete',
          callback: (args) {
            if (!completer.isCompleted) completer.complete();
            return null;
          },
        );
      },
    );
    try {
      await headless.run();
      // Wait for the collection iframe to signal completion, capped at 10s —
      // Cybersource's fingerprinting can take that long, but usually lands in
      // a second or two. The cap is the fallback if no signal arrives.
      await completer.future.timeout(const Duration(seconds: 10));
    } on TimeoutException {
      // No completion signal — proceed anyway; device data is best-effort.
    } finally {
      await headless.dispose();
    }
  }

  /// Shows the 3DS challenge full-screen and resolves with its outcome.
  static Future<CardChallengeResult> showChallenge(
    BuildContext context, {
    required String stepUpUrl,
    required String accessToken,
    required String md,
  }) {
    return showGeneralDialog<CardChallengeResult>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: Colors.black,
      barrierLabel: '3-D Secure',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _CardChallengeView(
          stepUpUrl: stepUpUrl,
          accessToken: accessToken,
          md: md,
        );
      },
    ).then((result) => result ?? CardChallengeResult.cancelled);
  }
}

/// The hidden 10×10 iframe form POST that runs Cybersource device data
/// collection (see Cybersource Payer Authentication → Step 2).
String _ddcHtml({
  required String deviceDataCollectionUrl,
  required String accessToken,
}) {
  return '''
<html>
<body>
  <iframe id="collectionIframe" name="collectionIframe"
    onload="onDdcLoad()"
    sandbox="allow-forms allow-scripts allow-same-origin allow-pointer-lock allow-popups"
    allow="payment *; publickey-credentials-get *; publickey-credentials-create *"
    height="10" width="10" style="display:none;"></iframe>
  <form id="collectionForm" method="POST" target="collectionIframe"
    action="$deviceDataCollectionUrl">
    <input id="collectionFormInput" type="hidden" name="JWT" value="$accessToken" />
  </form>
  <script>
    // The iframe fires `load` once for its initial about:blank document and
    // once more when the device-data-collection POST response lands — the
    // second load is the completion signal handed back to Flutter.
    var ddcLoads = 0;
    function onDdcLoad() {
      ddcLoads++;
      if (ddcLoads >= 2) {
        window.flutter_inappwebview.callHandler('ddcComplete');
      }
    }
    document.getElementById('collectionForm').submit();
  </script>
</body>
</html>
''';
}

/// A parent page hosting the 3DS challenge iframe. It form-POSTs the access
/// token (JWT) + merchant data (MD) to the step-up URL; the ACS then redirects
/// the iframe to the backend's finalize endpoint, which runs
/// `window.parent.postMessage({event, data}, "*")`. This page forwards that
/// message to Flutter through a JavaScript handler.
String _challengeHtml({
  required String stepUpUrl,
  required String accessToken,
  required String md,
}) {
  return '''
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
</head>
<body style="margin:0;padding:0;background:#fff;height:100%;">
  <iframe id="stepUpIframe" name="stepUpIframe"
    sandbox="allow-forms allow-scripts allow-same-origin allow-pointer-lock allow-popups"
    allow="payment *; publickey-credentials-get *; publickey-credentials-create *"
    style="width:100%;height:100%;border:0;position:fixed;top:0;left:0;right:0;bottom:0;"></iframe>
  <form id="stepUpForm" target="stepUpIframe" method="post" action="$stepUpUrl">
    <input type="hidden" name="JWT" value="$accessToken" />
    <input type="hidden" name="MD" value="$md" />
  </form>
  <script>
    window.addEventListener('message', function(event) {
      try {
        window.flutter_inappwebview.callHandler('on3DSResult', JSON.stringify(event.data));
      } catch (e) {
        window.flutter_inappwebview.callHandler('on3DSResult', JSON.stringify({ event: '3DS_CHALLENGE_FAILED', data: String(e) }));
      }
    });
    document.getElementById('stepUpForm').submit();
  </script>
</body>
</html>
''';
}

class _CardChallengeView extends StatefulWidget {
  const _CardChallengeView({
    required this.stepUpUrl,
    required this.accessToken,
    required this.md,
  });

  final String stepUpUrl;
  final String accessToken;
  final String md;

  @override
  State<_CardChallengeView> createState() => _CardChallengeViewState();
}

class _CardChallengeViewState extends State<_CardChallengeView> {
  bool _settled = false;
  Timer? _timeout;

  @override
  void initState() {
    super.initState();
    // Safety net: if the ACS never completes (hung or blank step-up page),
    // fail the challenge instead of leaving the user stuck on a spinnerless
    // screen. Legitimate challenges finish well within this window.
    _timeout = Timer(const Duration(minutes: 3), () {
      _settle(CardChallengeResult.failed);
    });
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  void _settle(CardChallengeResult result) {
    if (_settled) return;
    _settled = true;
    _timeout?.cancel();
    Navigator.of(context).pop(result);
  }

  void _handleResult(List<dynamic> args) {
    if (!mounted || _settled) return;
    try {
      final data = json.decode(args.first as String) as Map<String, dynamic>;
      switch (data['event']?.toString()) {
        case '3DS_CHALLENGE_COMPLETED':
          _settle(CardChallengeResult.completed);
        case '3DS_CHALLENGE_FAILED':
          _settle(CardChallengeResult.failed);
        case '3DS_CHALLENGE_CANCELLED':
          _settle(CardChallengeResult.cancelled);
      }
    } catch (_) {
      // Malformed message — ignore.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Verify card'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _settle(CardChallengeResult.cancelled),
        ),
      ),
      body: InAppWebView(
        initialData: InAppWebViewInitialData(
          data: _challengeHtml(
            stepUpUrl: widget.stepUpUrl,
            accessToken: widget.accessToken,
            md: widget.md,
          ),
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          javaScriptCanOpenWindowsAutomatically: true,
          iframeAllow:
              "camera *; microphone *; payment *; publickey-credentials-get *; publickey-credentials-create *",
        ),
        onWebViewCreated: (controller) {
          controller.addJavaScriptHandler(
            handlerName: 'on3DSResult',
            callback: (args) {
              _handleResult(args);
              return null;
            },
          );
        },
        onReceivedError: (controller, request, error) {
          _settle(CardChallengeResult.failed);
        },
        onReceivedHttpError: (controller, request, errorResponse) {
          _settle(CardChallengeResult.failed);
        },
      ),
    );
  }
}
