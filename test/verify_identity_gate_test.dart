import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/cache/process_store.dart';
import 'package:bigpay/data/cache/request_input_store.dart';
import 'package:bigpay/data/cache/response_cache.dart';
import 'package:bigpay/data/database/db.dart';
import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/models/actions/logout_action.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/pages/kyc/kyc.dart';
import 'package:bigpay/ui/pages/kyc/verify_identity_prompt.dart';
import 'package:bigpay/utils/message.util.dart';

/// Lets the test push states straight through the real bloc stream.
class _TestBloc extends ProcessBloc {
  _TestBloc()
      : super(
          store: ProcessStore(
            cache: ResponseCache(Database()),
            inputs: RequestInputStore(),
          ),
        );
  void push(ProcessState state) => emit(state);
}

void main() {
  testWidgets(
      '6000 opens the verify prompt once; the screen closes its loader and '
      'shows no error dialog', (tester) async {
    final bloc = _TestBloc();
    final event = ExecuteProcessEvent(
      id: 'e1',
      action: LogoutAction(payload: NoPayload()),
    );
    final navKey = GlobalKey<NavigatorState>();
    final seen = <ProcessSnapshot>[];

    final router = GoRouter(
      navigatorKey: navKey,
      routes: [
        GoRoute(
          path: '/feature',
          builder: (_, _) => Scaffold(
            body: ProcessListener<Null>(
              event: () => event,
              // A typical screen listener: loader on, loader off, error dialog.
              listener: (context, snapshot) {
                seen.add(snapshot);
                if (snapshot.isLoading) {
                  MessageUtil.displayLoading(context);
                  return;
                }
                MessageUtil.close(context);
                if (snapshot.hasError) {
                  MessageUtil.displayErrorDialog(context,
                      message: snapshot.error!.message);
                }
              },
              child: const Text('feature'),
            ),
          ),
        ),
      ],
      initialLocation: '/feature',
    );

    await tester.pumpWidget(BlocProvider<ProcessBloc>.value(
      value: bloc,
      child: VerifyIdentityGate(
        navigatorKey: navKey,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    bloc.push(ExecutingProcess(event: event, isCachedData: false, isSilent: false));
    await tester.pump();
    bloc.push(ExecuteProcessError(
      event: event,
      error: const DataError(
        code: '6000',
        status: 'ERROR',
        message: 'Please complete your identity verification to access this feature.',
      ),
      isCachedData: false,
      isSilent: false,
    ));
    await tester.pumpAndSettle();

    expect(seen.last.hasError, isFalse);
    expect(find.text('Verify Your Identity'), findsOneWidget);
    expect(find.text('Start Verification'), findsOneWidget);
    expect(
      find.text('Please complete your identity verification to access this feature.'),
      findsNothing,
    );
    expect(Kyc.route?.path, '/feature');
  });
}
