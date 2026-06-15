import 'dart:async';

import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:bigpay/models/walkthrough_data.dart';

class WalkthroughPage extends StatefulWidget {
  const WalkthroughPage({super.key});
  static String routeName = '/walkthrough';

  @override
  State<WalkthroughPage> createState() => _WalkthroughPageState();
}

class _WalkthroughPageState extends State<WalkthroughPage> {
  final PageController _pageController = PageController(
    initialPage: 0,
  );
  int _currentPage = 0;
  // InitializationResponse? data;

  static const walkThrough = [
    WalkthroughData(
      title: 'Securely Sent. Instantly.',
      subtitle:
          'Manage your virtual wallet with a futuristic interface designed for speed and complete peace of mind.',
      image: 'assets/img/walkthrough-1.jpg',
    ),
    WalkthroughData(
      title: 'Securely Sent. Instantly.',
      subtitle:
          'Manage your virtual wallet with a futuristic interface designed for speed and complete peace of mind.',
      image: 'assets/img/walkthrough-1.jpg',
    ),
  ];

  Widget _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < walkThrough.length; i++) {
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

  Timer? _timer;
  bool _pause = false;

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
        // final data = (context.read<AppBloc>().data);
        // if (data == null) {
        //   return;
        // }

        if (_pause) {
          return;
        }
        if (_currentPage == walkThrough.length - 1) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: .expand,
        alignment: .center,
        children: [
          PageView(
            dragStartBehavior: .start,
            controller: _pageController,
            onPageChanged: _nextPage,
            pageSnapping: true,
            padEnds: false,
            scrollDirection: Axis.horizontal,
            children: walkThrough
                .map(
                  (item) => Stack(
                    children: [
                      Image.asset(item.image),
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
                      onPressed: () {},
                      text: 'Create a New Account',
                    ),
                    TextButton(
                      onPressed: () {},
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
