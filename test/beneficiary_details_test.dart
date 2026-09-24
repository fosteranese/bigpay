import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/cache/process_store.dart';
import 'package:bigpay/data/cache/request_input_store.dart';
import 'package:bigpay/data/cache/response_cache.dart';
import 'package:bigpay/data/database/db.dart';
import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/pages/beneficiary/beneficiary_details.pg.dart';

void main() {
  testWidgets('remove asks first; cancel keeps it; copy confirms; fits 320dp @1.3x',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);

    await tester.pumpWidget(BlocProvider<ProcessBloc>(
      create: (_) => ProcessBloc(
        store: ProcessStore(
          cache: ResponseCache(Database()),
          inputs: RequestInputStore(),
        ),
      ),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: const BeneficiaryDetailsView(
          payee: Payee(
            payeeId: 'p1',
            title: 'Ama Mensah Owusu',
            formName: 'Mobile Money',
            formData: {'AccountNumber': '0244123456789', 'Network': 'MTN'},
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Account Number'), findsOneWidget);

    await tester.tap(find.text('Remove Beneficiary'));
    await tester.pumpAndSettle();
    expect(find.text('Remove Ama Mensah Owusu from your beneficiaries?'),
        findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Remove Ama Mensah Owusu from your beneficiaries?'),
        findsNothing);
    expect(find.text('Account Number'), findsOneWidget);

    await tester.tap(find.byTooltip('Copy').first);
    await tester.pump();
    expect(find.text('Copied'), findsOneWidget);
  });
}
