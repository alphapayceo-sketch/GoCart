import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  BiometricAuthService._();

  static const String _biometricEnabledKey = 'biometric_login_enabled';
  static const String _emailKey = 'secure_biometric_email';
  static const String _passwordKey = 'secure_biometric_password';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isSupportedOnDevice() async {
    if (kIsWeb) {
      return false;
    }

    try {
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      return isDeviceSupported && availableBiometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    if (kIsWeb) {
      return false;
    }

    try {
      final bool canAuthenticate = await _localAuth.isDeviceSupported();
      if (!canAuthenticate) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Confirm your identity to continue',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (error) {
      debugPrint('Biometric authentication error: $error');
      return false;
    }
  }

  static Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    if (kIsWeb) {
      return;
    }

    await _storage.write(key: _emailKey, value: email.trim());
    await _storage.write(key: _passwordKey, value: password);
  }

  static Future<void> clearCredentials() async {
    if (kIsWeb) {
      return;
    }

    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordKey);
  }

  static Future<Map<String, String>> getSavedCredentials() async {
    if (kIsWeb) {
      return const {};
    }

    final email = await _storage.read(key: _emailKey) ?? '';
    final password = await _storage.read(key: _passwordKey) ?? '';

    return {
      'email': email,
      'password': password,
    };
  }

  static Future<bool> hasSavedCredentials() async {
    final credentials = await getSavedCredentials();
    return credentials['email']?.isNotEmpty == true &&
        credentials['password']?.isNotEmpty == true;
  }

  static Future<void> setEnabled(bool value) async {
    if (kIsWeb) {
      return;
    }

    if (!value) {
      await clearCredentials();
    }

    await _storage.write(
      key: _biometricEnabledKey,
      value: value ? 'true' : 'false',
    );
  }

  static Future<bool> isEnabled() async {
    if (kIsWeb) {
      return false;
    }

    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }
}
