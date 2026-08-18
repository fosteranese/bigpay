import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/outline_button.dart';
import 'package:bigpay/ui/components/glass_panel.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';

final class MessageUtil {
  static void displayLoading(
    BuildContext context, {
    String? title,
    String? message,
  }) {
    showDialog(
      context: context,
      useRootNavigator: true,
      useSafeArea: false,
      barrierDismissible: false,
      fullscreenDialog: true,
      requestFocus: true,
      barrierColor: Colors.transparent,
      builder: (context) => GlassPanel(
        child: ZoomIn(
          child: FadeIn(
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const RotationLoader(),
                  if (message != null) const SizedBox(height: 15),
                  if (message != null)
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTypography.header2.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void displayErrorDialog(
    BuildContext context, {
    String? title,
    String? message,
    String okButtonText = 'Ok',
    void Function()? onOkPressed,
    Widget? customButton,
  }) {
    showDialog(
      barrierColor: Colors.black.withAlpha((0.8 * 224).toInt()),
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (context) => ZoomIn(
        child: FadeIn(
          child: Dialog(
            backgroundColor: context.cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.danger,
                    size: 55,
                  ),
                  const SizedBox(height: 10),
                  if (title != null)
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.header1.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  if (message != null) const SizedBox(height: 5),
                  if (message != null)
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: context.p1,
                    ),
                  const SizedBox(height: 20),
                  FormButton(
                    height: 50,
                    onPressed: () {
                      Navigator.pop(context);
                      if (onOkPressed != null) {
                        onOkPressed();
                      }
                    },
                    text: okButtonText,
                  ),
                  ?customButton,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void displaySuccessDialog(
    BuildContext context, {
    String? title,
    String? message,
    void Function()? onOk,
  }) {
    showDialog(
      barrierColor: Colors.black.withAlpha((0.8 * 224).toInt()),
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (context) => ZoomIn(
        child: FadeIn(
          child: Dialog(
            backgroundColor: context.cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 42.5,
                    backgroundColor: AppColors.tintShade3,
                    child: Icon(
                      Icons.task_alt_outlined,
                      color: AppColors.success,
                      size: 45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (title != null)
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: context.header1,
                    ),
                  if (message != null) const SizedBox(height: 10),
                  if (message != null)
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: context.p1,
                    ),
                  const SizedBox(height: 20),
                  FormButton(
                    height: 50,
                    onPressed: () {
                      Navigator.pop(context);
                      if (onOk != null) {
                        onOk();
                      }
                    },
                    text: 'OK',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void displaySuccessFullDialog(
    BuildContext context, {
    String? title,
    required String message,
    void Function()? onOk,
    String btnText = 'Ok',
    Widget? successIcon,
    Widget? customBtn,
  }) {
    showDialog(
      fullscreenDialog: true,
      barrierColor: Colors.transparent,
      context: context,
      useRootNavigator: true,
      useSafeArea: false,
      builder: (context) => ZoomIn(
        child: FadeIn(
          child: MainLayout(
            showBackBtn: false,
            background: Align(
              alignment: .bottomCenter,
              child: SvgPicture.asset(SvgImages.splashBgIcon),
            ),
            bottomNav:
                customBtn ??
                FormButton(
                  onPressed: () {
                    AppRouter.router.pop();
                    onOk?.call();
                  },
                  text: btnText,
                ),
            child: Column(
              mainAxisSize: .max,
              crossAxisAlignment: .center,
              children: [
                successIcon ??
                    Icon(
                      Icons.check_circle_outline,
                      size: 100,
                      color: AppColors.success,
                    ),

                const SizedBox(height: 20),
                if (title?.isNotEmpty ?? false)
                  Text(
                    title ?? '',
                    style: context.display2,
                    textAlign: .center,
                  ),
                if (title?.isNotEmpty ?? false) const SizedBox(height: 10),
                Text(
                  message,
                  style: context.smallDetails,
                  textAlign: .center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void displayActionDialog(
    BuildContext context, {
    String? title,
    String? message,
    required void Function() onConfirm,
    Color onConfirmButtonColor = AppColors.secondary,
    Color onConfirmButtonTextColor = AppColors.primary,
    Widget? icon,
    String onConfirmText = 'Confirm',
  }) {
    showDialog(
      barrierColor: Colors.black.withAlpha((0.8 * 224).toInt()),
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (context) => ZoomIn(
        child: FadeIn(
          child: Dialog(
            backgroundColor: context.cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon ??
                      const Icon(
                        Icons.help_outline,
                        color: AppColors.primary,
                        size: 50,
                      ),
                  const SizedBox(height: 10),
                  if (title != null)
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: context.header1,
                    ),
                  if (message != null) const SizedBox(height: 5),
                  if (message != null)
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: context.p1,
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FormOutlineButton(
                          height: 50,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          text: 'Cancel',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FormButton(
                          backgroundColor: onConfirmButtonColor,
                          foregroundColor: onConfirmButtonTextColor,
                          height: 50,
                          onPressed: () {
                            Navigator.pop(context);
                            onConfirm();
                          },
                          text: onConfirmText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Dismisses the top-most dialog (e.g. the loading dialog).
  ///
  /// Pops the root navigator, matching `useRootNavigator: true` on the
  /// dialogs — go_router's `context.pop()` targets its own route stack and
  /// leaves a root-navigator dialog open.
  static void close(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) navigator.pop();
  }
}

class RotationLoader extends StatefulWidget {
  const RotationLoader({
    super.key,
  });

  @override
  State<RotationLoader> createState() => _RotationLoaderState();
}

class _RotationLoaderState extends State<RotationLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 56,
      child: RotationTransition(
        turns: _controller,
        child: Image.asset('assets/img/loader.png'),
      ),
    );
  }
}
