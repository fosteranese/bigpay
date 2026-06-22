import 'package:bigpay/routes/app_router.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/profile',
  );

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final _otp = ValueNotifier('');

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      bottomSize: 150,
      title: 'Account',
      subtitleWidget: InkWell(
        borderRadius: .circular(12),
        onTap: () {},
        child: Container(
          margin: .only(top: 20),
          padding: .symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: .circular(12),
          ),
          child: ListTile(
            dense: false,
            contentPadding: .zero,
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.white,
            ),
            title: Text(
              'Tom Dockery Adjei Mensah',
              maxLines: 1,
              style: AppTypography.p1.copyWith(
                color: AppColors.white,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right_outlined,
              color: AppColors.white,
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          ProfileItem(
            title: 'Security',
            icon: Icons.admin_panel_settings_outlined,
          ),
          ProfileItem(
            title: 'Submit a Complaint',
            icon: Icons.send_outlined,
          ),
          ProfileItem(
            title: 'Call Us',
            icon: Icons.phone_outlined,
          ),
          ProfileItem(
            title: 'Email Us',
            icon: Icons.email_outlined,
          ),
          ProfileItem(
            title: 'Contact us via WhatsApp',
            icon: Icons.help_outlined,
          ),
          ProfileItem(
            title: 'Privacy Statement',
            icon: Icons.privacy_tip_outlined,
          ),
          ProfileItem(
            backgroundColor: AppColors.danger.withValues(alpha: 0.2),
            iconColor: AppColors.danger,
            title: 'Sign Out',
            icon: Icons.logout_outlined,
          ),
        ],
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  const ProfileItem({
    super.key,
    this.backgroundColor = AppColors.tintShade3,
    this.iconColor = AppColors.secondary,
    required this.title,
    required this.icon,
    this.trailing,
  });

  final Color backgroundColor;
  final Color iconColor;
  final String title;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: false,
      contentPadding: .zero,
      leading: CircleAvatar(
        radius: 20.5,
        backgroundColor: backgroundColor,
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.p1,
      ),
      trailing: trailing ?? Icon(Icons.chevron_right_outlined),
    );
  }
}
