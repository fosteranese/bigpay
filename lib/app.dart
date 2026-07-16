import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/models/actions/startup_action.dart';
import 'package:bigpay/ui/pages/app_error.pg.dart';
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
          if (state is ExecuteProcessError) {
            // The GoRouter is installed by the MaterialApp.router *below* this
            // listener, so `context.go` can't find it looking upwards. Drive
            // the router instance directly instead.
            AppRouter.router.go(
              AppErrorPage.route.path,
              extra: state.error,
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
