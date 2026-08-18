import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppModal {
  AppModal._();

  static void showBottomModal(
    BuildContext context, {
    required String label,
    required List<Widget> children,
    EdgeInsetsGeometry padding = const .all(10),
    List<Widget> actions = const [],
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      requestFocus: true,
      context: context,
      useSafeArea: true,
      useRootNavigator: true,
      isDismissible: true,
      constraints: BoxConstraints(
        minWidth: double.maxFinite,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: .circular(20),
      ),
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const .all(20),
        padding: padding,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: .circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            children: [
              Row(
                mainAxisSize: .max,
                mainAxisAlignment: .spaceBetween,
                crossAxisAlignment: .center,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: context.header1,
                    ),
                  ),
                  ...actions,
                  const SizedBox(width: 5),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      alignment: .center,
                      tapTargetSize: .shrinkWrap,
                      backgroundColor: context.divider,
                      fixedSize: Size(35, 35),
                      minimumSize: Size(35, 35),
                      maximumSize: Size(35, 35),
                    ),
                    onPressed: () {
                      context.pop();
                    },
                    icon: Icon(
                      Icons.close,
                      size: 17,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
