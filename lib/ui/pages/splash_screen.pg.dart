import 'package:bigpay/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/ui/theme/assets/app_images.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(path: '/splash-screen');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: .expand,
        alignment: .bottomCenter,
        children: [
          Align(alignment: .bottomCenter, child: SvgPicture.asset(SvgImages.splashBgIcon)),
          Align(alignment: .center, child: SvgPicture.asset(SvgImages.icon)),
        ],
      ),
    );
  }
}
