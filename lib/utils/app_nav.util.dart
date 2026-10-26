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
      return showGeneralDialog<T>(
        context: ctx,
        useRootNavigator: true,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor ?? const Color(0x80000000),
        barrierLabel: MaterialLocalizations.of(ctx).modalBarrierDismissLabel,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          final dialog = Dialog(
            clipBehavior: Clip.antiAlias,
            child: builder(context),
          );
          return useSafeArea ? SafeArea(child: dialog) : dialog;
        },
        // Smooth fade + slight rise — shared by the page → authenticator
        // entrance and the authenticator → authenticator hand-off.
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
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
        useRootNavigator: true,
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
