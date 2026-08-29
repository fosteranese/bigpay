import 'package:bigpay/ui/components/auth/pin_auth.dart';
import 'package:bigpay/utils/app_nav.util.dart';
import 'package:flutter/material.dart';

class AuthenticationUtil {
  static void start({
    required List<Map<String, dynamic>> authModes,
    required Map<String, dynamic> payload,
    required void Function({
      String? pin,
      String? secretAnswer,
      String? otp,
      required Map<String, dynamic> payload,
    })
    complete,
    void Function()? onResendShortCode,
  }) {
    String pin = '';
    String secretAnswer = '';
    String otp = '';

    Future<void> getLocationAndComplete() async {
      // await LocationUtil.locationInfo;
      complete(
        payload: payload,
        otp: otp,
        pin: pin,
        secretAnswer: secretAnswer,
      );
    }

    if (authModes.isEmpty) {
      getLocationAndComplete();
      return;
    }

    // authentication sequence
    int index = 0;
    authenticate() async {
      await Future.delayed(const Duration(seconds: 0));
      var authMode = authModes[index];
      switch (authMode['type']) {
        case 'PIN':
          AuthenticationUtil.pin(
            data: authMode['data'],
            onSuccess: (value) {
              ++index;
              pin = value;

              if (authModes.length != index) {
                authenticate();
              } else {
                getLocationAndComplete();
              }
            },
            allowBiometric: true,
          );
          break;
        case 'OTP':
          AuthenticationUtil.otp(
            authMode: authMode,
            onResendShortCode: onResendShortCode,
            onSuccess: (value) {
              ++index;
              otp = value;

              if (authModes.length != index) {
                authenticate();
              } else {
                getLocationAndComplete();
              }
            },
          );
          break;
        case 'SECRET_ANSWER':
        default:
          AuthenticationUtil.secretAnswer(
            onSuccess: (value) {
              ++index;
              secretAnswer = value;

              if (authModes.length != index) {
                authenticate();
              } else {
                getLocationAndComplete();
              }
            },
          );
          break;
      }
    }

    // start authenticate
    authenticate();
  }

  static Future pin({
    required void Function(String pin) onSuccess,
    required Map<String, dynamic> data,
    bool allowBiometric = false,
  }) {
    return AppNav.dialog(
      barrierDismissible: false,
      barrierColor: const Color(0xE0000000),
      useSafeArea: false,
      builder: (BuildContext context) {
        return PinAuthenticator(
          data: data,
          onSuccess: onSuccess,
          allowBiometric: allowBiometric,
          end: () => end(context),
        );
      },
    );
  }

  static Future secretAnswer({
    required void Function(String pin) onSuccess,
    bool allowBiometric = false,
  }) {
    return AppNav.dialog(
      barrierDismissible: true,
      barrierColor: Colors.white.withAlpha(153),
      useSafeArea: false,
      builder: (BuildContext context) {
        return Text('d');
        // return SecretAnswerAuthenticator(
        //   onSuccess: onSuccess,
        //   end: () => end(context),
        // );
      },
    );
  }

  static Future otp({
    required void Function(String pin) onSuccess,
    bool allowBiometric = false,
    required Map<String, dynamic> authMode,
    void Function()? onResendShortCode,
  }) {
    if (onResendShortCode != null) {
      onResendShortCode();
    }

    return AppNav.dialog(
      barrierDismissible: true,
      barrierColor: Colors.white.withAlpha(153),
      useSafeArea: false,
      builder: (BuildContext context) {
        return Text('d');
        // return OtpAuthenticator(
        //   authMode: authMode,
        //   onSuccess: onSuccess,
        //   onResendShortCode: onResendShortCode,
        //   end: () => end(context),
        // );
      },
    );
  }

  static void end(BuildContext context) {
    Navigator.of(context).pop();
  }

  static Future<String> getPin(BuildContext context) async {
    var pin = ''; //context.read<AuthBloc>().pin;

    if (pin.isNotEmpty) {
      return pin;
    }

    pin = ''; // await AppState.auth.getCurrentUserPin() ?? '';
    return pin;
  }
}
