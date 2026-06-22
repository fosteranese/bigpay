import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/feedback',
  );

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _phoneNumberFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      bottomSize: 112,
      title: 'Report an Issue',
      subtitle:
          'Encountered a problem? Tell us what went wrong, and our support team will get straight to work to resolve it for you.',
      bottomNav: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          Row(
            mainAxisSize: .max,
            mainAxisAlignment: .center,
            crossAxisAlignment: .center,
            children: [
              Icon(
                Icons.timer,
                size: 20,
                color: AppColors.flora,
              ),
              const SizedBox(width: 2),
              Text(
                'Our team typically responds within 2 hours.',
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: 10),
          FormButton(onPressed: () {}, text: 'Send Message'),
        ],
      ),
      child: Form(
        child: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          crossAxisAlignment: .center,
          children: [
            FormSelectInput(
              label: 'Select a category',
              placeholder: 'Search...',
              focusNode: _phoneNumberFocusNode,
              controller: TextEditingController(),

              next: (_) {
                _passwordFocusNode.requestFocus();
              },
            ),
            SizedBox(height: 15),
            FormInput(
              label: 'Subject',
              controller: TextEditingController(),
            ),
            SizedBox(height: 15),
            FormTextAreaInput(
              label: 'Message',
              placeholder: 'Details of your challenge here',
              controller: TextEditingController(),
            ),
          ],
        ),
      ),
    );
  }
}
