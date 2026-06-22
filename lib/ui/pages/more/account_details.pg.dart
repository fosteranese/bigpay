import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/profile-details',
  );

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      bottomSize: 100,
      flexibleSpace: Container(
        color: AppColors.white,
        child: Stack(
          children: [
            Container(
              height: 153,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5406, 1.0],
                  colors: const [
                    Color(0xFF221E55),
                    Color(0xFF20428C),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      subtitleWidget: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.white,
            child: CircleAvatar(
              radius: 33,
              backgroundColor: AppColors.tintShade3,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const .only(bottom: 30),
              child: Text(
                'Tom Dockery Adjei Mensah',
                style: AppTypography.formLabels.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          FormInput(
            label: 'First Name *',
            controller: TextEditingController(),
            readOnly: true,
          ),
          const SizedBox(height: 10),
          FormInput(
            label: 'Middle Name',
            controller: TextEditingController(),
            readOnly: true,
          ),
          const SizedBox(height: 10),
          FormInput(
            label: 'Last Name *',
            controller: TextEditingController(),
            readOnly: true,
          ),
          const SizedBox(height: 10),
          FormInput(
            label: 'Email Address *',
            controller: TextEditingController(),
            readOnly: true,
          ),
          const SizedBox(height: 10),
          FormInput(
            label: 'Date of Birth *',
            controller: TextEditingController(),
            readOnly: true,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FormInput(
                  label: 'Gender *',
                  controller: TextEditingController(),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FormInput(
                  label: 'Nationality',
                  controller: TextEditingController(),
                  readOnly: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
