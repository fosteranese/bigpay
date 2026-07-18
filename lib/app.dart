import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/initialization_data/initialization_data.dart';
import 'package:bigpay/models/actions/startup_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/pages/app_error.pg.dart';
import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/pages/walkthrough.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/utils/app_state.util.dart';

class BigPayApp extends StatelessWidget {
  const BigPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (_) => ProcessBloc(
            store: AppState.store,
          )..add(startUpEvent),
        ),
      ],
      child: ProcessListener<InitializationData>(
        event: startUpEvent,
        listener: (context, snapshot) {
          if (snapshot.hasData) {
            AppState.data = snapshot.data!;
            final returning = snapshot.isCached || snapshot.isSilent;
            AppRouter.router.go(
              returning ? NewLoginPage.route.path : WalkthroughPage.route.path,
              extra: snapshot.data,
            );
          } else if (snapshot.hasError &&
              !snapshot.isSilent &&
              !snapshot.isCached) {
            AppRouter.router.go(
              AppErrorPage.route.path,
              extra: snapshot.error,
            );
          }
        },
        child: MaterialApp.router(
          title: 'BigPay',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
