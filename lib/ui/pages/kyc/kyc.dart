import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/routes/app_router.dart';

class Kyc {
  Kyc._();

  static String ghanaCardNumber = '';

  /// Base64-encoded JPEG of the live selfie captured in the face-capture
  /// step — set by [FaceCaptureKycPage], read by [ContactInfoKycPage] as the
  /// picture submitted for verification.
  static String passportPicture = '';

  /// The face-capture step's own automated quality assessment for
  /// [passportPicture] — surfaced on [PicturePreviewKycPage]'s review
  /// checklist. Default to a passing state so a page reached without ever
  /// visiting the capture step (shouldn't happen in the real flow) doesn't
  /// show a false warning.
  static bool faceIsBlur = false;
  static bool faceHasObstructions = false;
  static bool faceIsWellLighted = true;

  static PageRouteDefinition? route;

  /// Re-runs the request that hit `6000` once KYC succeeds — only honoured
  /// when that request was [retryEvent] (see verify_identity_prompt.dart).
  static void Function()? onSuccess;
  static ProcessEvent? retryEvent;

  static void clear() {
    ghanaCardNumber = '';
    passportPicture = '';
    faceIsBlur = false;
    faceHasObstructions = false;
    faceIsWellLighted = true;
    route = null;
    onSuccess = null;
    retryEvent = null;
  }
}
