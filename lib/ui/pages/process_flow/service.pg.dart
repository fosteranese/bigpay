import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/app_modal.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/service',
  );

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      bottomSize: 50,
      title: 'Transfer Money',
      builder: (_) => SliverList.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: const .symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            child: ListTile(
              onTap: () {
                AppModal.showBottomModal(
                  context,
                  label: 'Verify Your Identity',
                  padding: .all(20),
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Finish setting up your profile to start sending, receiving, and managing your money securely.',
                      style: AppTypography.smallDetails.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: .bottomRight,
                      child: Text(
                        '60% Complete',
                        style: AppTypography.caption,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 8,
                      alignment: .centerLeft,
                      decoration: BoxDecoration(
                        borderRadius: .circular(20),
                        gradient: LinearGradient(
                          begin: Alignment
                              .topCenter, // 180deg points from top to bottom
                          end: Alignment.bottomCenter,
                          stops: [
                            0.0,
                            0.5052,
                            1.0,
                          ], // Exact CSS percentage stops
                          colors: [
                            Color(0xFFB7B7B7), // #B7B7B7 at 0%
                            Color(0xFFDFD6D6), // #DFD6D6 at 50.52%
                            Color(0xFFEFE1E1), // #EFE1E1 at 100%
                          ],
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraint) {
                          return Container(
                            width: 0.6 * constraint.maxWidth,
                            decoration: BoxDecoration(
                              borderRadius: .circular(20),
                              color: AppColors.secondary,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    FormButton(
                      height: 45,
                      onPressed: () {},
                      text: 'Start Verification',
                    ),
                  ],
                );
              },
              contentPadding: .symmetric(
                horizontal: 15,
              ),
              tileColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: .circular(14),
              ),
              leading: SvgPicture.asset('assets/img/transfer.svg'),
              title: Text(
                'Transfer Money',
                style: AppTypography.header4,
              ),
              subtitle: Text(
                'Send funds anywhere securely',
                style: AppTypography.caption,
              ),
              trailing: Icon(Icons.chevron_right_outlined),
            ),
          );
        },
      ),
    );
  }
}
