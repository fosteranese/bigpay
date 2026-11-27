import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/cache/process_store.dart';
import 'package:bigpay/data/cache/request_input_store.dart';
import 'package:bigpay/data/cache/response_cache.dart';
import 'package:bigpay/data/database/db.dart';
import 'package:bigpay/data/models/account/account.dart';
import 'package:bigpay/data/models/account/source.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/pages/wallets/virtual.pg.dart';

Future<void> _pump(WidgetTester tester, Account account) async {
  await tester.pumpWidget(
    BlocProvider<ProcessBloc>(
      create: (_) => ProcessBloc(
        store: ProcessStore(
          cache: ResponseCache(Database()),
          inputs: RequestInputStore(),
        ),
      ),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VirtualWalletPage(account: account),
      ),
    ),
  );
  // Tests have no network: the request fails, as a real outage would.
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  testWidgets('a failed load shows a title and the real error, not "Retry"', (
    tester,
  ) async {
    await _pump(
      tester,
      const Account(
        title: 'W',
        hasMiniStatement: true,
        sources: [Source(value: '001', tile: 'W')],
      ),
    );
    expect(find.text("Couldn't load transactions"), findsOneWidget);
    expect(
      find.text(
        'We couldn\'t process your request at this time. Please attempt it again',
      ),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('a wallet without a mini statement shows empty, no request', (
    tester,
  ) async {
    await _pump(
      tester,
      const Account(
        title: 'W',
        hasMiniStatement: false,
        sources: [Source(value: '001', tile: 'W')],
      ),
    );
    expect(find.text("Couldn't load transactions"), findsNothing);
    expect(find.text('No transactions yet'), findsOneWidget);
  });
}
