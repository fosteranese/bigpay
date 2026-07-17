import 'dart:async';

import 'package:bigpay/ui/pages/auth/signin/signin.dart';
import 'package:bigpay/ui/pages/auth/signup/signup.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:bigpay/models/actions/startup_action.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:bigpay/models/walkthrough_data.dart';

class WalkthroughPage extends StatefulWidget {
  const WalkthroughPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(path: '/walkthrough');

  @override
  State<WalkthroughPage> createState() => _WalkthroughPageState();
}

class _WalkthroughPageState extends State<WalkthroughPage> {
  final _pageController = PageController(
    initialPage: 0,
  );
  int _currentPage = 0;
  List<WalkthroughData> _walkThrough = const [];
  Timer? _timer;
  bool _pause = false;

  Widget _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _walkThrough.length; i++) {
      list.add(
        i == _currentPage ? _indicator(true) : _indicator(false),
      );
    }
    return Padding(
      padding: const .only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: list,
      ),
    );
  }

  @override
  void initState() {
    _slide();
    super.initState();
  }

  void _slide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) {
      try {
        if (_walkThrough.isEmpty) {
          return;
        }

        if (_pause) {
          return;
        }
        if (_currentPage == _walkThrough.length - 1) {
          // _currentPage = 0;
          // _pageController.jumpToPage(_currentPage);
        } else {
          ++_currentPage;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(seconds: 1),
            curve: Curves.ease,
          );
        }
      } catch (_) {
        // logger.i('Auto-scroll animation failed');
      }
    });
  }

  Widget _indicator(bool isActive) {
    var size = 9.0;
    var activeSize = 10.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 3.0),
      height: isActive ? activeSize : size,
      width: isActive ? activeSize : size,
      decoration: BoxDecoration(
        color: isActive ? AppColors.white : AppColors.flora,
        borderRadius: .all(
          .circular(size),
        ),
      ),
    );
  }

  final buttonKey = GlobalKey();

  void _nextPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  /// The slide image, falling back to the bundled asset.
  ///
  /// The payload names a file (`Walkthrough_2.jpg`) and the host arrives with
  /// it, so the URL is only as good as what the backend reports — an
  /// unreachable one has to degrade to the asset rather than leave a hole in
  /// the first screen of the app. Both the loading and error states show the
  /// bundled image, so there is never a blank frame on this screen.
  Widget _slideImage(WalkthroughData item) {
    final fallback = Image.asset(
      JpgImages.walkthrough1,
      alignment: .center,
      fit: .cover,
    );

    final url = item.imageUrl;
    if (url == null) {
      return fallback;
    }

    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => fallback,
      errorWidget: (context, url, error) => fallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProcessBuilder<List<WalkthroughData>>(
      event: startUpEvent,
      builder: (context, snapshot) {
        _walkThrough = snapshot.data ?? _walkThrough;

        return _buildContent();
      },
    );
  }

  Widget _buildContent() {
    return Scaffold(
      body: Stack(
        fit: .expand,
        alignment: .center,
        children: [
          PageView(
            physics: ClampingScrollPhysics(),
            dragStartBehavior: .start,
            controller: _pageController,
            onPageChanged: _nextPage,
            pageSnapping: true,
            padEnds: false,
            scrollDirection: .horizontal,
            children: _walkThrough
                .map(
                  (item) => Stack(
                    children: [
                      _slideImage(item),
                      Align(
                        alignment: .topCenter,
                        child: SafeArea(
                          child: Padding(
                            padding: const .symmetric(
                              horizontal: 20,
                              vertical: 40,
                            ),
                            child: Column(
                              mainAxisSize: .min,
                              mainAxisAlignment: .start,
                              crossAxisAlignment: .start,
                              children: [
                                Text(
                                  item.title,
                                  style: AppTypography.display1,
                                ),
                                Text(
                                  item.subtitle,
                                  style: AppTypography.smallDetails.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Container(
                        height: double.maxFinite,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: .topCenter,
                            end: .bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.black.withAlpha(125),
                              AppColors.black.withAlpha(240),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),

          Align(
            alignment: .bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const .all(20),
                child: Column(
                  mainAxisSize: .min,
                  mainAxisAlignment: .end,
                  crossAxisAlignment: .center,
                  children: [
                    _buildPageIndicator(),
                    FormButton(
                      onPressed: () {
                        AppRouter.router.push(
                          StartSignUpPage.route.path,
                        );
                      },
                      text: 'Create a New Account',
                    ),
                    TextButton(
                      onPressed: () {
                        AppRouter.router.push(
                          NewLoginPage.route.path,
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an Account? ',
                              style: AppTypography.smallDetails.copyWith(
                                color: AppColors.offWhite,
                              ),
                            ),
                            TextSpan(
                              text: 'Sign In',
                              style: AppTypography.buttons.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
