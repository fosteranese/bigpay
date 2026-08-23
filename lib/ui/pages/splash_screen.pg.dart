import 'package:bigpay/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/ui/theme/responsive.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/splash-screen',
  );

  // The asset's own viewBox — 375x403 — used to scale it without distortion.
  static const _bgIconAspectRatio = 375 / 403;

  @override
  Widget build(BuildContext context) {
    // The background icon has a fixed intrinsic size (375x403, matching a
    // standard phone width) and doesn't scale on its own. Below that width
    // it overflows off-screen on a small/candy-bar phone; above it, scale it
    // to the same content cap the rest of the app uses (via contentCapWidth,
    // so it also matches whatever BoundedContent below actually gives it) so
    // it doesn't look lost on a tablet or desktop window.
    final cap = contentCapWidth(context);
    final bgIconWidth = cap == double.infinity
        ? MediaQuery.sizeOf(context).width
        : cap;

    return Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        // Matches MainLayout's background — every other page in the app
        // gets this gradient; without it, this pre-auth page fell through
        // to the flat theme scaffold color, reading as a "white patch" next
        // to the rest of the app's chrome.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3077],
            colors: [context.scaffoldBg, context.cardBg],
          ),
        ),
        child: BoundedContent(
          child: Stack(
            fit: .expand,
            alignment: .bottomCenter,
            children: [
              Align(
                alignment: .bottomCenter,
                child: SvgPicture.asset(
                  SvgImages.splashBgIcon,
                  width: bgIconWidth,
                  height: bgIconWidth / _bgIconAspectRatio,
                ),
              ),
              Align(
                alignment: .center,
                child: SvgPicture.asset(SvgImages.icon),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
