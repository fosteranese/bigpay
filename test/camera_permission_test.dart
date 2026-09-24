import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/pages/kyc/camera_permission.dart';

// permission_handler's wire values.
const _denied = 0, _granted = 1, _permanentlyDenied = 4;
const _channel = MethodChannel('flutter.baseflow.com/permissions/methods');

/// Fakes the platform: [status] now, [afterRequest] once the prompt answers.
List<String> _fake(WidgetTester tester, int status, {int? afterRequest}) {
  final calls = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(_channel,
      (call) async {
    calls.add(call.method);
    switch (call.method) {
      case 'checkPermissionStatus':
        return status;
      case 'requestPermissions':
        status = afterRequest ?? status;
        return {1: status}; // 1 = Permission.camera
      case 'openAppSettings':
        return true;
    }
    return null;
  });
  return calls;
}

Future<bool?> _run(WidgetTester tester, {String? tap}) async {
  bool? result;
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () async => result = await ensureCameraPermission(context),
        child: const Text('go'),
      ),
    ),
  ));
  await tester.tap(find.text('go'));
  await tester.pumpAndSettle();
  if (tap != null) {
    expect(find.text('Camera access needed'), findsOneWidget);
    await tester.tap(find.text(tap));
    await tester.pumpAndSettle();
  }
  return result;
}

void main() {
  testWidgets('already granted: proceeds, no prompt, no sheet', (tester) async {
    final calls = _fake(tester, _granted);
    expect(await _run(tester), isTrue);
    expect(calls, isNot(contains('requestPermissions')));
  });

  testWidgets('not asked yet: system prompt, proceeds once granted',
      (tester) async {
    final calls = _fake(tester, _denied, afterRequest: _granted);
    expect(await _run(tester), isTrue);
    expect(calls, contains('requestPermissions'));
  });

  testWidgets('refused for good: explains, offers Settings, does not proceed',
      (tester) async {
    final calls = _fake(tester, _permanentlyDenied);
    expect(await _run(tester, tap: 'Open Settings'), isFalse);
    expect(calls, contains('openAppSettings'));
  });

  testWidgets('refused at the prompt, then Cancel: does not proceed',
      (tester) async {
    final calls = _fake(tester, _denied, afterRequest: _permanentlyDenied);
    expect(await _run(tester, tap: 'Cancel'), isFalse);
    expect(calls, isNot(contains('openAppSettings')));
  });
}
