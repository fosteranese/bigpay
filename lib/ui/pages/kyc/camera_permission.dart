import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/components/confirm_sheet.dart';

/// Gate in front of the selfie camera: true once camera access is granted.
///
/// Not asked yet (or asked once on Android) → the system prompt. Refused for
/// good, or restricted → a sheet explaining why, offering Settings (the only
/// place it can be changed from then on), and false.
Future<bool> ensureCameraPermission(BuildContext context) async {
  var status = await Permission.camera.status;
  if (status.isDenied) status = await Permission.camera.request();
  if (status.isGranted) return true;
  if (!context.mounted) return false;

  final l10n = AppLocalizations.of(context)!;
  final openSettings = await showConfirmSheet(
    context,
    icon: Icons.camera_alt_outlined,
    title: l10n.kycCameraPermissionTitle,
    message: l10n.kycCameraPermissionMessage,
    confirmText: l10n.kycOpenSettings,
    destructive: false,
  );
  if (openSettings) await openAppSettings();
  return false;
}
