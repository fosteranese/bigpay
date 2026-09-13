import 'dart:convert';
import 'dart:io';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/auth_data/preview_datum.dart';
import 'package:bigpay/models/actions/change_profile_picture_action.dart';
import 'package:bigpay/models/actions/get_profile_picture_action.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/utils/app_modal.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:bigpay/utils/message.util.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  ExecuteProcessEvent? _changePictureEvent;

  /// Fields shown here come straight from the backend's own
  /// `user.previewData` rather than fixed fields on [User] — the same
  /// approach umb's profile page uses. `User` also has firstName/lastName/
  /// email/etc. fields directly, but this account doesn't have those
  /// populated; whatever the backend considers this user's displayable
  /// profile lives in previewData instead.
  List<PreviewDatum> get _details {
    return (AppState.currentUser?.user?.previewData ?? const [])
        .where((item) => (item.key ?? '').isNotEmpty)
        .toList();
  }

  Future<void> _pickImage(ImageSource source) async {
    AppRouter.router.pop();
    final file = await ImagePicker().pickImage(source: source);
    if (file == null || !mounted) return;

    final bytes = await File(file.path).readAsBytes();
    if (!mounted) return;

    setState(() {
      _changePictureEvent = context.dispatchProcess(
        ChangeProfilePictureAction(
          payload: ChangeProfilePictureActionPayload(
            picture: base64Encode(bytes),
          ),
        ),
      );
    });
  }

  void _showChangePictureSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    AppModal.showBottomModal(
      context,
      label: l10n.profileUpdatePictureTitle,
      padding: const .all(20),
      children: [
        const SizedBox(height: 10),
        ListTile(
          contentPadding: .zero,
          leading: CircleAvatar(
            backgroundColor: context.avatarBg,
            child: Icon(Icons.camera_alt_outlined, color: context.accentGreen),
          ),
          title: Text(l10n.profileTakePicture, style: context.formLabels),
          trailing: Icon(Icons.chevron_right_outlined),
          onTap: () => _pickImage(ImageSource.camera),
        ),
        ListTile(
          contentPadding: .zero,
          leading: CircleAvatar(
            backgroundColor: context.avatarBg,
            child: Icon(Icons.photo_library_outlined, color: context.accentGreen),
          ),
          title: Text(l10n.profileChooseFromGallery, style: context.formLabels),
          trailing: Icon(Icons.chevron_right_outlined),
          onTap: () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ProcessListener<String>(
      event: () => _changePictureEvent,
      listener: (context, snapshot) {
        if (snapshot.isLoading) {
          MessageUtil.displayLoading(context);
          return;
        } else {
          MessageUtil.close(context);
        }

        if (snapshot.isSuccessful) {
          _changePictureEvent = null;
          setState(() {
            AppState.currentUser = AppState.currentUser!.copyWith(
              profilePicture: snapshot.data ?? '',
            );
          });
          MessageUtil.displaySuccessDialog(
            context,
            message: l10n.profilePictureUpdatedMessage,
          );
          return;
        }

        if (snapshot.hasError) {
          _changePictureEvent = null;
          MessageUtil.displayErrorDialog(
            context,
            message: snapshot.error!.message,
          );
        }
      },
      child: MainLayout(
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
            GestureDetector(
              onTap: () => _showChangePictureSheet(context),
              child: Stack(
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
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const .all(3),
                      decoration: BoxDecoration(
                        color: context.accentGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.cardBg, width: 1.5),
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 12,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
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
            for (final item in _details) ...[
              FormInput(
                label: item.key,
                controller: TextEditingController(text: item.value ?? ''),
                readOnly: true,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
