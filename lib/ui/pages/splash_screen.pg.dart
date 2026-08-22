import 'package:bigpay/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    // to the same content cap the rest of the app uses so it doesn't look
    // lost on a tablet or desktop window.
    final bgIconWidth = context.responsive<double>(
      compact: MediaQuery.sizeOf(context).width,
      medium: 640,
      expanded: 720,
    );

    return Scaffold(
      body: Stack(
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
          Align(alignment: .center, child: SvgPicture.asset(SvgImages.icon)),
        ],
      ),
    );
  }
}
