import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/pages/kyc/intro-kyc.pg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Ghana card spans full width on a candybar phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: IntroKycPage(),
    ));
    await tester.pump();
    // An unrelated 8px header overflow (test font metrics) pre-exists on
    // this page; only guard against the unbounded-height SVG crash.
    expect('${tester.takeException() ?? ''}', isNot(contains('infinite')));
    final rect = tester.getRect(find.byType(SvgPicture));
    expect(rect.left, 0);
    expect(rect.right, 390);
  });
}
