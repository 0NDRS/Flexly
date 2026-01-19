import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockService {
  static const _keyPasscodeEnabled = 'privacy_passcode';
  static const _keyPasscodeCode = 'privacy_passcode_code';
  static const _keyBiometricEnabled = 'privacy_biometric';

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isPasscodeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPasscodeEnabled) ?? false;
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  Future<String?> getPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPasscodeCode);
  }

  Future<void> setPasscode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPasscodeCode, code);
    await prefs.setBool(_keyPasscodeEnabled, true);
  }

  Future<void> setPasscodeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPasscodeEnabled, enabled);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, enabled);
  }

  Future<bool> canUseBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final available = await canUseBiometrics();
      if (!available) return false;
      return await _localAuth.authenticate(
        localizedReason: 'Unlock Flexly',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}