import 'dart:convert';

import 'package:bigpay/models/actions/get_profile_picture_action.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/more/profile',
  );

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      bottomSize: 100,
      flexibleSpace: Container(
        color: context.cardBg,
        child: Stack(
          children: [
            Container(
              height: 175,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5406, 1.0],
                  colors: AppGradients.walletCard.colors,
                ),
              ),
            ),
          ],
        ),
      ),
      subtitleWidget: Row(
        children: [
          ProcessBuilder<String>(
            event: () => GetProfilePictureAction.event,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                AppState.currentUser = AppState.currentUser!.copyWith(
                  profilePicture: snapshot.data ?? '',
                );
                return CircleAvatar(
                  radius: 18,
                  backgroundColor: context.avatarBg,
                  backgroundImage: MemoryImage(
                    base64Decode(
                      AppState.currentUser?.profilePicture ?? '',
                    ),
                  ),
                );
              }

              return CircleAvatar(
                radius: 36,
                backgroundColor: context.cardBg,
                child: CircleAvatar(
                  radius: 33,
                  backgroundColor: context.avatarBg,
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const .only(bottom: 30),
              child: Text(
                AppState.currentUser?.user?.name ?? '',
                style: context.formLabels.copyWith(
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
            label: l10n.profileFirstNameLabel,
            controller: TextEditingController(
              text: AppState.currentUser?.user?.firstName ?? '',
            ),
            readOnly: true,
          ),
          const SizedBox(height: 10),
          FormInput(
            label: l10n.profileMiddleNameLabel,
            controller: TextEditingController(
              text: AppState.currentUser?.user?.middleName ?? '',
            ),
            readOnly: true,
          ),
          const SizedBox(height: 10),
          FormInput(
            label: l10n.profileLastNameLabel,
            controller: TextEditingController(
              text: AppState.currentUser?.user?.lastName ?? '',
            ),
            readOnly: true,
          ),
          const SizedBox(height: 10),
          FormInput(
            label: l10n.profileEmailAddressLabel,
            controller: TextEditingController(
              text: AppState.currentUser?.user?.email ?? '',
            ),
            readOnly: true,
          ),
          const SizedBox(height: 10),
          FormInput(
            label: l10n.profileDateOfBirthLabel,
            controller: TextEditingController(
              text: AppState.currentUser?.user?.birthDate ?? '',
            ),
            readOnly: true,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FormInput(
                  label: l10n.profileGenderLabel,
                  controller: TextEditingController(
                    text: AppState.currentUser?.user?.gender ?? '',
                  ),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FormInput(
                  label: l10n.profileNationalityLabel,
                  controller: TextEditingController(
                    text: AppState.currentUser?.user?.nationality ?? '',
                  ),
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
