import 'dart:convert';

import 'package:bigpay/ui/pages/beneficiary/beneficiaries.pg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bigpay/models/actions/action.dart';
import 'package:bigpay/models/actions/get_profile_picture_action.dart';
import 'package:bigpay/models/actions/logout_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/more/complaints/complaints.pg.dart';
import 'package:bigpay/ui/pages/more/help.pg.dart';
import 'package:bigpay/ui/pages/more/profile.pg.dart';
import 'package:bigpay/ui/pages/more/security.pg.dart';
import 'package:bigpay/ui/pages/process_flow/feedback.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/app_state.util.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/more',
  );

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
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
        onTap: () {
          AppRouter.router.push(ProfilePage.route.path);
        },
        child: Container(
          margin: .only(top: 20),
          padding: .symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: .circular(12),
          ),
          child: Material(
            color: AppColors.primary,
            child: ListTile(
              dense: false,
              contentPadding: .zero,
              leading: ProcessBuilder<String>(
                event: () => GetProfilePictureAction.event,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    AppState.currentUser = AppState.currentUser!.copyWith(
                      profilePicture: snapshot.data ?? '',
                    );
                    return CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.white,
                      backgroundImage: MemoryImage(
                        base64Decode(
                          AppState.currentUser?.profilePicture ?? '',
                        ),
                      ),
                    );
                  }

                  return CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.white,
                  );
                },
              ),
              title: Text(
                AppState.currentUser?.user?.name ?? '',
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
      ),
      child: Column(
        children: [
          ProfileItem(
            onPressed: () {
              AppRouter.router.push(BeneficiariesPage.route.path);
            },
            title: 'Beneficiaries',
            icon: Icons.group_outlined,
          ),
          ProfileItem(
            onPressed: () {
              AppRouter.router.push(SecurityPage.route.path);
            },
            title: 'Security',
            icon: Icons.admin_panel_settings_outlined,
          ),
          ProfileItem(
            onPressed: () {
              AppRouter.router.push(FeedbackPage.route.path);
            },
            title: 'Submit a Complaint',
            icon: Icons.send_outlined,
          ),
          ProfileItem(
            onPressed: () {
              AppRouter.router.push(ComplaintsPage.route.path);
            },
            title: 'Complaints',
            icon: Icons.forum_outlined,
          ),
          ProfileItem(
            onPressed: () {
              AppRouter.router.push(HelpPage.route.path);
            },
            title: 'Help',
            icon: Icons.help_outline,
          ),
          ProfileItem(
            onPressed: () {
              final url = Uri.parse(
                AppState.data?.help?.privacyUrl ?? '',
              );
              launchUrl(url);
            },
            title: 'Privacy Statement',
            icon: Icons.privacy_tip_outlined,
          ),
          ProfileItem(
            onPressed: () {
              LogoutAction.event = context.dispatchProcess(
                LogoutAction(
                  payload: NoPayload(),
                ),
              );
            },
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
    this.icon,
    this.iconUrl,
    this.iconSvg,
    this.trailing,
    this.onPressed,
  });

  final Color backgroundColor;
  final Color iconColor;
  final String title;
  final IconData? icon;
  final String? iconUrl;
  final String? iconSvg;
  final Widget? trailing;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onPressed,
        dense: false,
        contentPadding: .zero,
        leading: CircleAvatar(
          radius: 20.5,
          backgroundColor: backgroundColor,
          child: Builder(
            builder: (context) {
              if (iconSvg?.isNotEmpty ?? false) {
                return SvgPicture.asset(iconSvg ?? '');
              }

              if (iconUrl?.isNotEmpty ?? false) {
                return CircleAvatar(
                  radius: 20.5,
                  backgroundColor: AppColors.tintShade3,
                  child: CachedNetworkImage(
                    imageUrl: iconUrl!,
                    width: 22,
                    height: 22,
                    placeholder: (context, url) => Icon(
                      Icons.shield_outlined,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.shield_outlined,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ),
                );
              }

              if (icon != null) {
                return Icon(
                  icon,
                  color: iconColor,
                );
              }

              return Icon(
                Icons.circle_outlined,
                color: iconColor,
              );
            },
          ),
        ),
        title: Text(
          title,
          style: AppTypography.p1,
        ),
        trailing: trailing ?? Icon(Icons.chevron_right_outlined),
      ),
    );
  }
}
