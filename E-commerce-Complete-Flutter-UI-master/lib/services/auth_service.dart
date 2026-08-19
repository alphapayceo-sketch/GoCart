import 'package:shop/config/app_config.dart';
import 'package:shop/services/api_client.dart';
import 'package:shop/services/biometric_auth_service.dart';

class AuthService {
  const AuthService();

  static String currentUserName = 'User';
  static String currentUserEmail = '';
  static String currentUserImage = '';
  static String currentUserRole = 'user';

  static bool get isAdmin {
    return currentUserRole == 'admin' ||
        currentUserEmail.toLowerCase() == 'linkofx@gmail.com';
  }

  static bool get isMerchant => currentUserRole == 'merchant' || isAdmin;

  static String _extractString(
      Map<String, dynamic> payload, List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return '';
  }

  static String _buildFallbackAvatar(String email) {
    return 'https://i.pravatar.cc/100?u=${Uri.encodeComponent(email)}';
  }

  static String _normalizeAvatarUrl(String? imageUrl, String email) {
    final normalized = (imageUrl ?? '').trim();
    if (normalized.isEmpty) {
      return _buildFallbackAvatar(email);
    }

    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return normalized;
    }

    if (normalized.startsWith('/')) {
      return '${AppConfig.current.baseUrl}$normalized';
    }

    if (normalized.startsWith('storage/')) {
      return '${AppConfig.current.baseUrl}/$normalized';
    }

    return normalized;
  }

  static String? extractTokenFromResponse(Map<String, dynamic> response) {
    final payload = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;

    final token = _extractString(payload, [
      'token',
      'access_token',
      'accessToken',
      'jwt',
      'authToken',
      'authorization',
    ]);

    if (token.isEmpty) {
      return null;
    }

    if (token.toLowerCase().startsWith('bearer ')) {
      return token.substring(7).trim();
    }

    return token;
  }

  static void setSessionProfile({
    required String? firstName,
    required String? lastName,
    required String email,
    String? imageUrl,
  }) {
    final cleanedEmail = email.trim();
    final first = (firstName ?? '').trim();
    final last = (lastName ?? '').trim();

    currentUserName =
        [first, last].where((value) => value.isNotEmpty).join(' ');
    if (currentUserName.isEmpty) {
      currentUserName = cleanedEmail.split('@').first;
    }

    currentUserEmail = cleanedEmail;
    currentUserImage = _normalizeAvatarUrl(imageUrl, cleanedEmail);
  }

  static Future<void> logout() async {
    ApiClient.clearAuthToken();
    await BiometricAuthService.clearCredentials();
    currentUserName = 'User';
    currentUserEmail = '';
    currentUserImage = '';
    currentUserRole = 'user';
  }

  static void setSessionProfileFromResponse(
    Map<String, dynamic> response, {
    required String fallbackEmail,
  }) {
    final payload = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;

    final user = payload['user'] is Map<String, dynamic>
        ? payload['user'] as Map<String, dynamic>
        : payload;

    currentUserRole = _extractString(user, ['role']).isNotEmpty
        ? _extractString(user, ['role'])
        : 'user';

    final imageUrl = _extractString(user, [
      'avatar_url',
      'image_url',
      'profile_image',
      'image',
      'photo_url',
      'avatar',
    ]);

    setSessionProfile(
      firstName: _extractString(user, ['first_name', 'firstName']),
      lastName: _extractString(user, ['last_name', 'lastName']),
      email: _extractString(user, ['email']).isNotEmpty
          ? _extractString(user, ['email'])
          : fallbackEmail,
      imageUrl: imageUrl,
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.postJson('/api/auth/login', {
      'email': email,
      'password': password,
    });

    final token = extractTokenFromResponse(response);
    if (token != null && token.isNotEmpty) {
      ApiClient.setAuthToken(token);
    }

    await BiometricAuthService.saveCredentials(
      email: email,
      password: password,
    );

    setSessionProfileFromResponse(response, fallbackEmail: email);
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password,
    String role = 'customer',
  }) async {
    final body = <String, String>{
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'phone_number': phoneNumber.trim(),
      'email': email,
      'password': password,
      'role': role,
    };

    final response = await ApiClient.postJson('/api/auth/signup', body);

    final token = extractTokenFromResponse(response);
    if (token != null && token.isNotEmpty) {
      ApiClient.setAuthToken(token);
    }

    setSessionProfileFromResponse(response, fallbackEmail: email);
  }

  Future<void> verifyEmail(
      {required String email, required String code}) async {
    await ApiClient.postJson('/api/auth/verify-email', {
      'email': email.trim(),
      'code': code.trim(),
    });
  }

  Future<void> resendVerification(String email) async {
    await ApiClient.postJson('/api/auth/resend-verification', {
      'email': email.trim(),
    });
  }
}
