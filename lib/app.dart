import 'package:flutter/material.dart';
import 'routes/app_router.dart';
import 'ui/theme/app_theme.dart';

class BigPayApp extends StatelessWidget {
  const BigPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: 'BigPay', debugShowCheckedModeBanner: false, theme: AppTheme.light, routerConfig: AppRouter.router);
  }
}
