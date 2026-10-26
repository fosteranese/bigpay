import 'package:local_auth/local_auth.dart';

import 'package:bigpay/utils/app_state.util.dart';

/// Outcome of a biometric prompt — lets callers tell a user cancel/failure
/// apart from the device having no biometrics set up.
enum BiometricResult { success, failed, unavailable }

/// Device biometrics plus the persisted "biometric enabled" settings.
///
/// The flags and the saved PIN live in [AppState.db] — an encrypted Hive box —
/// so the PIN captured when biometrics are enabled can be replayed after a
/// successful fingerprint/Face ID at login or transaction time.
class BiometricUtil {
  BiometricUtil._();

  static final _auth = LocalAuthentication();

  static const _loginKey = 'biometric-login';
  static const _transactionKey = 'biometric-transaction';
  static const _pinKey = 'biometric-pin';
  static const _passwordKey = 'biometric-password';

  /// Whether the device can authenticate at all. Lenient (OR) — the real gate
  /// is [authenticate], which reports whether biometrics are actually enrolled.
  static Future<bool> get isAvailable async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Prompts the device biometric (Face ID / fingerprint).
  ///
  /// Returns [BiometricResult.success] when the user authenticates,
  /// [BiometricResult.unavailable] when the device has no biometrics set up
  /// (so the caller can tell them to enrol), and [BiometricResult.failed] for a
  /// cancel or a mismatch. This is the authoritative check — a pre-flight
  /// `canCheckBiometrics` is unreliable and wrongly blocks enrolled devices.
  static Future<BiometricResult> authenticate(String reason) async {
    try {
      final result = await _auth.isDeviceSupported();
      if (!result) {
        return BiometricResult.unavailable;
      }

      final ok = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        // sensitiveTransaction: true,
        sensitiveTransaction: false,
      );
      return ok ? BiometricResult.success : BiometricResult.failed;
    } on LocalAuthException catch (e) {
      switch (e.code) {
        case LocalAuthExceptionCode.noCredentialsSet:
        case LocalAuthExceptionCode.noBiometricsEnrolled:
        case LocalAuthExceptionCode.noBiometricHardware:
        case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
          return BiometricResult.unavailable;
        default:
          return BiometricResult.failed;
      }
    } catch (_) {
      return BiometricResult.failed;
    }
  }

  // --- persisted settings (encrypted Hive box) ---

  static Future<bool> _flag(String key) async {
    final record = await AppState.db.read(key);
    return (record?['status'] as bool?) ?? false;
  }

  static Future<bool> get isLoginEnabled => _flag(_loginKey);
  static Future<bool> get isTransactionEnabled => _flag(_transactionKey);

  static Future<void> setLoginEnabled(bool value) =>
      AppState.db.add(key: _loginKey, payload: {'status': value});

  static Future<void> setTransactionEnabled(bool value) =>
      AppState.db.add(key: _transactionKey, payload: {'status': value});

  static Future<void> savePin(String pin) =>
      AppState.db.add(key: _pinKey, payload: {'pin': pin});

  static Future<String?> readPin() async {
    final record = await AppState.db.read(_pinKey);
    return record?['pin'] as String?;
  }

  /// The login password captured for biometric sign-in (bigpay logs in with a
  /// password, not the PIN — so login and transaction biometrics store
  /// different secrets).
  static Future<void> saveLoginPassword(String password) =>
      AppState.db.add(key: _passwordKey, payload: {'password': password});

  static Future<String?> readLoginPassword() async {
    final record = await AppState.db.read(_passwordKey);
    return record?['password'] as String?;
  }

  /// Clears the biometric settings and the stored secrets (e.g. on logout).
  static Future<void> clear() async {
    await AppState.db.delete(_loginKey);
    await AppState.db.delete(_transactionKey);
    await AppState.db.delete(_pinKey);
    await AppState.db.delete(_passwordKey);
  }
}
