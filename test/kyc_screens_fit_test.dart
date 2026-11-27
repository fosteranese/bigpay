import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/pages/kyc/info-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/intro-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/preview-picture-kyc.pg.dart';

void main() {
  // A real proportional font so text wraps and measures like it does on a
  // phone (the default test font's square glyphs exaggerate every text
  // block). The app no longer bundles fonts (Apple fonts are disallowed), so
  // load Roboto — the Material text-theme default — from the Flutter SDK.
  setUpAll(() async {
    final loader = FontLoader('Roboto');
    final fonts = _flutterFontsDir();
    if (fonts == null) return;
    for (final w in ['Regular', 'Medium', 'Bold']) {
      final file = File('$fonts/Roboto-$w.ttf');
      if (!file.existsSync()) continue;
      loader.addFont(
        file.readAsBytes().then((b) => ByteData.sublistView(b)),
      );
    }
    await loader.load();
  });

  // Regression: an SvgPicture reports no height until loaded, so the page's
  // SliverFillRemaining sized the column short and it overflowed (seen on an
  // iPhone 17 Pro Max). Checked on the first frames, before the SVG loads.
  final pages = <String, Widget>{
    'intro': const IntroKycPage(),
    'selfie info': const InfoKycPage(),
    'photo review': const PicturePreviewKycPage(),
  };
  for (final MapEntry(key: name, value: page) in pages.entries) {
    for (final size in const [Size(440, 956), Size(375, 667)]) {
      testWidgets('$name fits at ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        // Real-phone conditions: notch/home-indicator insets and the largest
        // text size the app allows (clamped to 1.3x in app.dart).
        tester.view.padding = const FakeViewPadding(top: 62, bottom: 34);
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: page,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}

/// The SDK's Material font directory (Roboto), walking up from the test
/// executable, or null when not found (tests then fall back to the default
/// test font).
String? _flutterFontsDir() {
  var dir = File(Platform.resolvedExecutable).parent;
  while (dir.path != dir.parent.path) {
    final probe =
        '${dir.path}/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf';
    if (File(probe).existsSync()) {
      return '${dir.path}/bin/cache/artifacts/material_fonts';
    }
    dir = dir.parent;
  }
  return null;
}
