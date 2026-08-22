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
import 'package:bigpay/utils/avatar.util.dart';
import 'package:bigpay/utils/message.util.dart';

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
                      backgroundColor: context.cardBg,
                      backgroundImage: avatarFromBase64(
                        AppState.currentUser?.profilePicture,
                      ),
                    );
                  }

                  return CircleAvatar(
                    radius: 25,
                    backgroundColor: context.cardBg,
                  );
                },
              ),
              title: Text(
                AppState.currentUser?.user?.name ?? '',
                maxLines: 1,
                style: context.p1.copyWith(
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
          _buildThemeSwitcher(),
          Divider(
            color: context.divider,
            thickness: 4,
            indent: 10,
            endIndent: 10,
          ),
          const SizedBox(height: 8),
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
              final url = AppState.data?.help?.privacyUrl ?? '';
              if (url.isEmpty) return;
              launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
            },
            title: 'Privacy Statement',
            icon: Icons.privacy_tip_outlined,
          ),
          Divider(
            color: context.divider,
            thickness: 4,
            indent: 10,
            endIndent: 10,
            height: 30,
          ),
          ProfileItem(
            onPressed: () {
              MessageUtil.displayActionDialog(
                context,
                title: 'Sign Out',
                message: 'Are you sure you want to sign out?',
                onConfirmText: 'Sign Out',
                onConfirmButtonColor: AppColors.danger,
                onConfirmButtonTextColor: AppColors.white,
                icon: Icon(
                  Icons.logout_outlined,
                  color: AppColors.danger,
                  size: 50,
                ),
                onConfirm: () {
                  LogoutAction.event = context.dispatchProcess(
                    LogoutAction(
                      payload: NoPayload(),
                    ),
                  );
                },
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

  Widget _buildThemeSwitcher() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppState.themeNotifier,
      builder: (context, current, _) {
        return Container(
          padding: const .only(bottom: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.5,
                backgroundColor: context.avatarBg,
                child: Icon(
                  Icons.dark_mode_outlined,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Theme',
                style: context.p1,
              ),
              const Spacer(),
              for (final mode in ThemeMode.values) ...[
                if (mode != ThemeMode.values.first) const SizedBox(width: 6),
                _ThemeChip(
                  label: mode == ThemeMode.light
                      ? 'Light'
                      : mode == ThemeMode.dark
                      ? 'Dark'
                      : 'Auto',
                  selected: current == mode,
                  onTap: () => AppState.setTheme(mode),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const .symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: .circular(8),
            border: Border.all(
              color: selected ? AppColors.primary : context.border,
            ),
          ),
          child: Text(
            label,
            style: context.smallBold.copyWith(
              color: selected ? AppColors.white : context.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  const ProfileItem({
    super.key,
    this.backgroundColor,
    this.iconColor = AppColors.secondary,
    required this.title,
    this.icon,
    this.iconUrl,
    this.iconSvg,
    this.trailing,
    this.onPressed,
  });

  final Color? backgroundColor;
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
          backgroundColor: backgroundColor ?? context.avatarBg,
          child: Builder(
            builder: (context) {
              if (iconSvg?.isNotEmpty ?? false) {
                return SvgPicture.asset(iconSvg ?? '');
              }

              if (iconUrl?.isNotEmpty ?? false) {
                return CircleAvatar(
                  radius: 20.5,
                  backgroundColor: context.avatarBg,
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
          style: context.p1,
        ),
        trailing: trailing ?? Icon(Icons.chevron_right_outlined),
      ),
    );
  }
}
