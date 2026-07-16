import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bigpay/routes/app_router.dart';

class AppNav {
  AppNav._();

  static BuildContext? get context =>
      AppRouter.router.routerDelegate.navigatorKey.currentContext;

  static void go(String location, {Object? extra}) {
    final ctx = context;
    if (ctx != null) ctx.go(location, extra: extra);
  }

  static void pop<T>([T? result]) {
    final ctx = context;
    if (ctx != null) ctx.pop(result);
  }

  static Future<T?> dialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
  }) {
    final ctx = context;
    if (ctx != null) {
      return showDialog<T>(
        context: ctx,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        useSafeArea: useSafeArea,
        builder: builder,
      );
    }
    return Future.value(null);
  }

  static Future<T?> sheet<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    Color? backgroundColor,
    bool useSafeArea = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final ctx = context;
    if (ctx != null) {
      return showModalBottomSheet<T>(
        context: ctx,
        isScrollControlled: isScrollControlled,
        backgroundColor: backgroundColor,
        useSafeArea: useSafeArea,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        builder: builder,
      );
    }
    return Future.value(null);
  }

  static T read<T>() => context!.read<T>();

  static T readOr<T>(BuildContext? fallback) =>
      (context ?? fallback)!.read<T>();
}
