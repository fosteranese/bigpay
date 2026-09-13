import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kyc_face_capture/kyc_face_capture.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/kyc/kyc.dart';
import 'package:bigpay/ui/pages/kyc/preview-picture-kyc.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

enum _CameraAccess { checking, granted, denied }

/// The KYC "selfie" step's actual camera screen — [kyc_face_capture]'s
/// guided liveness/pose capture, gated behind a camera-permission check the
/// package itself doesn't do. A capture hands its result to [Kyc] and moves
/// on to [PicturePreviewKycPage] to review before submitting.
class FaceCaptureKycPage extends StatefulWidget {
  const FaceCaptureKycPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/kyc/face-capture',
  );

  @override
  State<FaceCaptureKycPage> createState() => _FaceCaptureKycPageState();
}

class _FaceCaptureKycPageState extends State<FaceCaptureKycPage> {
  var _access = _CameraAccess.checking;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    if (!mounted) return;
    setState(() {
      _access = status.isGranted ? _CameraAccess.granted : _CameraAccess.denied;
    });
  }

  void _onCaptured(FaceCaptureResult result) {
    Kyc.passportPicture = base64Encode(result.jpeg);
    Kyc.faceIsBlur = result.isBlur;
    Kyc.faceHasObstructions = result.hasObstructions;
    Kyc.faceIsWellLighted = result.isWellLighted;
    AppRouter.router.push(PicturePreviewKycPage.route.path);
  }

  @override
  Widget build(BuildContext context) {
    switch (_access) {
      case _CameraAccess.checking:
        // Matches FaceCaptureScreen's own loading treatment so there's no
        // visible flash-of-different-background before it takes over.
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()),
        );
      case _CameraAccess.granted:
        return FaceCaptureScreen(onFaceCaptured: _onCaptured);
      case _CameraAccess.denied:
        return const _CameraPermissionDenied();
    }
  }
}

class _CameraPermissionDenied extends StatelessWidget {
  const _CameraPermissionDenied();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MainLayout(
      bottomNav: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          FormButton(
            onPressed: openAppSettings,
            text: l10n.kycOpenSettings,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => AppRouter.router.pop(),
            child: Text(
              l10n.commonBack,
              style: context.smallDetails.copyWith(
                color: context.textPrimary,
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
          Icon(
            Icons.camera_alt_outlined,
            size: 72,
            color: context.textSecondary,
          ),
          const SizedBox(height: Spacing.xl),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 285),
            child: Text(
              l10n.kycCameraPermissionTitle,
              textAlign: .center,
              style: context.display2,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 285),
            child: Text(
              l10n.kycCameraPermissionMessage,
              textAlign: .center,
              style: context.smallDetails,
            ),
          ),
        ],
      ),
    );
  }
}
