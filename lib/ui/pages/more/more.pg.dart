import 'package:bigpay/ui/pages/beneficiary/beneficiaries.pg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bigpay/l10n/app_localizations.dart';
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
import 'package:bigpay/ui/components/forms/radio_button.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

import 'package:bigpay/utils/app_modal.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/avatar.util.dart';
import 'package:bigpay/utils/message.util.dart';

/// Each supported language's own name, in that language — shown in the
/// picker regardless of the app's current display language, so a user can
/// always recognize their language even if the UI is currently in the wrong
/// one. Not part of the ARB files: this must never be translated.
const _languageNames = {
  'en': 'English',
  'de': 'Deutsch',
  'es': 'Español',
  'fr': 'Français',
  'ar': 'العربية',
  'pcm': 'Pidgin',
};

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
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      bottomSize: 150,
      title: l10n.moreAccountTitle,
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
          const SizedBox(height: Spacing.sm),
          _buildLanguageSwitcher(),
          Divider(
            color: context.divider,
            thickness: 4,
            indent: 10,
            endIndent: 10,
          ),
          const SizedBox(height: Spacing.sm),
          ProfileItem(
            onPressed: () {
              AppRouter.router.push(BeneficiariesPage.route.path);
            },
            title: l10n.moreBeneficiaries,
            icon: Icons.group_outlined,
          ),
          ProfileItem(
            onPressed: () {
              AppRouter.router.push(SecurityPage.route.path);
            },
            title: l10n.securityTitle,
            icon: Icons.admin_panel_settings_outlined,
          ),
          ProfileItem(
            onPressed: () {
              AppRouter.router.push(FeedbackPage.route.path);
            },
            title: l10n.moreSubmitComplaint,
            icon: Icons.send_outlined,
          ),
          ProfileItem(
            onPressed: () {
              AppRouter.router.push(ComplaintsPage.route.path);
            },
            title: l10n.complaintsTitle,
            icon: Icons.forum_outlined,
          ),
          ProfileItem(
            onPressed: () {
              AppRouter.router.push(HelpPage.route.path);
            },
            title: l10n.helpTitle,
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
            title: l10n.morePrivacyStatement,
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
                title: l10n.moreSignOutTitle,
                message: l10n.moreSignOutConfirm,
                onConfirmText: l10n.moreSignOutTitle,
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
            title: l10n.moreSignOutTitle,
            icon: Icons.logout_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSwitcher() {
    return ValueListenableBuilder<Locale?>(
      valueListenable: AppState.localeNotifier,
      builder: (context, current, _) {
        final l10n = AppLocalizations.of(context)!;
        return InkWell(
          borderRadius: .circular(12),
          onTap: () => _openLanguagePicker(context, current),
          child: Container(
            padding: const .only(bottom: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.5,
                  backgroundColor: context.avatarBg,
                  child: Icon(
                    Icons.language_outlined,
                    color: context.accentGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: Spacing.lg),
                Text(
                  l10n.settingsLanguage,
                  style: context.p1,
                ),
                const Spacer(),
                Text(
                  current == null
                      ? l10n.moreThemeAuto
                      : (_languageNames[current.languageCode] ??
                            current.languageCode),
                  style: context.smallDetails.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                Icon(
                  Icons.chevron_right_outlined,
                  color: context.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openLanguagePicker(BuildContext context, Locale? current) {
    final l10n = AppLocalizations.of(context)!;
    AppModal.showBottomModal(
      context,
      label: l10n.settingsLanguage,
      children: [
        const SizedBox(height: 10),
        _languageOption(
          label: l10n.moreThemeAuto,
          selected: current == null,
          onTap: () {
            AppState.setLocale(null);
            Navigator.pop(context);
          },
        ),
        for (final locale in AppState.supportedLocales)
          _languageOption(
            label: _languageNames[locale.languageCode] ?? locale.languageCode,
            selected: current?.languageCode == locale.languageCode,
            onTap: () {
              AppState.setLocale(locale);
              Navigator.pop(context);
            },
          ),
      ],
    );
  }

  Widget _languageOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const .only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: .circular(10),
        border: .all(
          color: context.border,
          width: 1,
        ),
      ),
      child: Material(
        borderRadius: .circular(10),
        child: ListTile(
          onTap: onTap,
          selected: selected,
          title: Text(label),
          contentPadding: .symmetric(horizontal: 10),
          trailing: FormRadioButton(selected: selected),
        ),
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
                  color: context.accentGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: Spacing.lg),
              Text(
                AppLocalizations.of(context)!.moreThemeLabel,
                style: context.p1,
              ),
              const Spacer(),
              for (final mode in ThemeMode.values) ...[
                if (mode != ThemeMode.values.first) const SizedBox(width: 6),
                _ThemeChip(
                  label: mode == ThemeMode.light
                      ? AppLocalizations.of(context)!.moreThemeLight
                      : mode == ThemeMode.dark
                      ? AppLocalizations.of(context)!.moreThemeDark
                      : AppLocalizations.of(context)!.moreThemeAuto,
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
    this.iconColor,
    required this.title,
    this.icon,
    this.iconUrl,
    this.iconSvg,
    this.trailing,
    this.onPressed,
  });

  final Color? backgroundColor;
  final Color? iconColor;
  final String title;
  final IconData? icon;
  final String? iconUrl;
  final String? iconSvg;
  final Widget? trailing;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? context.accentGreen;
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
                      color: effectiveIconColor,
                      size: 22,
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.shield_outlined,
                      color: effectiveIconColor,
                      size: 22,
                    ),
                  ),
                );
              }

              if (icon != null) {
                return Icon(
                  icon,
                  color: effectiveIconColor,
                );
              }

              return Icon(
                Icons.circle_outlined,
                color: effectiveIconColor,
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
