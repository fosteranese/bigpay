import 'package:bigpay/blocs/process/process_bloc.dart';
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
          create: (context) => ProcessBloc(),
        ),
      ],
      child: MaterialApp.router(
        title: 'BigPay',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
