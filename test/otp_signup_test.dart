import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/cache/process_store.dart';
import 'package:bigpay/data/cache/request_input_store.dart';
import 'package:bigpay/data/cache/response_cache.dart';
import 'package:bigpay/data/database/db.dart';
import 'package:bigpay/data/models/start_sign_up_data/start_sign_up_data.dart';
import 'package:bigpay/ui/pages/auth/signup/otp_signup.pg.dart';

/// The OTP page subscribes to [ProcessBloc] (for OTP resend), so it needs one
/// in the tree. The bloc is never driven here, so its store is never touched.
Widget _wrap(Widget child) {
  return BlocProvider<ProcessBloc>(
    create: (_) => ProcessBloc(
      store: ProcessStore(cache: ResponseCache(Database()), inputs: RequestInputStore()),
    ),
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('masks all but the last 3 digits of the number', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const OtpSignUpPage(phoneNumber: '0244123219', data: StartSignUpData()),
      ),
    );
    await tester.pump();

    expect(
      find.text('Enter the 6-digit code sent to *******219'),
      findsOneWidget,
    );
  });

  testWidgets('falls back to generic copy for a too-short number', (tester) async {
    await tester.pumpWidget(
      _wrap(const OtpSignUpPage(phoneNumber: '', data: StartSignUpData())),
    );
    await tester.pump();

    expect(
      find.text('Enter the 6-digit code sent to your phone'),
      findsOneWidget,
    );
  });
}
