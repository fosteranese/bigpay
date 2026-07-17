import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/models/actions/startup_action.dart';
import 'package:bigpay/ui/pages/app_error.pg.dart';
import 'package:bigpay/ui/pages/walkthrough.pg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'routes/app_router.dart';
import 'ui/theme/app_theme.dart';

class BigPayApp extends StatelessWidget {
  const BigPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (_) => ProcessBloc()..add(startUpEvent),
        ),
      ],
      child: BlocListener<ProcessBloc, ProcessState>(
        listenWhen: (previous, current) => current.event == startUpEvent,
        listener: (context, state) {
          // ProcessState is sealed, so the states that route nowhere are listed
          // rather than defaulted: adding a new one breaks the build here
          // instead of silently falling through.
          switch (state) {
            case ProcessExecuted(:final data):
              AppRouter.router.go(
                WalkthroughPage.route.path,
                extra: data,
              );
            case ExecuteProcessError(:final error):
              AppRouter.router.go(
                AppErrorPage.route.path,
                extra: error,
              );
            case InitialProcess():
            case ExecutingProcess():
              break;
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
