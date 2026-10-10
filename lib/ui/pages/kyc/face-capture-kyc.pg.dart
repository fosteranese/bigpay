import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kyc_face_capture/kyc_face_capture.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/forms/outline_button.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/kyc/kyc.dart';
import 'package:bigpay/ui/pages/kyc/preview-picture-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/kyc_hero.dart';
import 'package:bigpay/ui/theme/app_theme.dart';

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
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    // Android keeps the app alive while the user flips the toggle in
    // Settings, so re-read on return. Status only — requesting here would
    // loop, since the permission dialog itself triggers a resume.
    _lifecycle = AppLifecycleListener(onResume: _recheckPermission);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _recheckPermission() async {
    if (_access != _CameraAccess.denied) return;
    final status = await Permission.camera.status;
    if (!mounted || !status.isGranted) return;
    setState(() => _access = _CameraAccess.granted);
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
      bottomSize: 0,
      bottomNav: Column(
        mainAxisSize: .min,
        children: [
          FormButton(
            onPressed: openAppSettings,
            text: l10n.kycOpenSettings,
          ),
          const SizedBox(height: Spacing.md),
          FormOutlineButton(
            onPressed: () => AppRouter.router.pop(),
            text: l10n.commonBack,
          ),
        ],
      ),
      child: KycHero(
        visual: Icon(
          Icons.camera_alt_outlined,
          size: 72,
          color: context.textSecondary,
        ),
        title: l10n.kycCameraPermissionTitle,
        subtitle: l10n.kycCameraPermissionMessage,
      ),
    );
  }
}
