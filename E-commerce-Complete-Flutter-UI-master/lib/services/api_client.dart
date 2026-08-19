import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shop/config/app_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode = 0});

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final http.Client _client = http.Client();
  static String? _authToken;

  static String get _baseUrl => AppConfig.current.baseUrl;

  static bool get hasAuthToken => _authToken != null && _authToken!.isNotEmpty;

  static void setAuthToken(String? token) {
    final cleaned = token?.trim();
    _authToken = cleaned != null && cleaned.isNotEmpty ? cleaned : null;
  }

  static void clearAuthToken() {
    _authToken = null;
  }

  static Map<String, String> get _jsonHeaders => <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (AppConfig.current.tenantId.trim().isNotEmpty)
          'X-Tenant-ID': AppConfig.current.tenantId.trim(),
        if (hasAuthToken) 'Authorization': 'Bearer $_authToken',
      };

  static void _handleUnauthorized(int statusCode) {
    if (statusCode == 401) {
      clearAuthToken();
    }
  }

  static Future<List<dynamic>> getList(String path) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl$path'),
      headers: _jsonHeaders,
    );

    if (response.statusCode == 401) {
      _handleUnauthorized(response.statusCode);
      throw const ApiException(
          'Your session has expired. Please sign in again.');
    }

    if (response.statusCode != 200) {
      throw ApiException('Failed to load $path (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      return decoded['data'] as List<dynamic>;
    }

    if (decoded is Map<String, dynamic> && decoded['items'] is List) {
      return decoded['items'] as List<dynamic>;
    }

    throw const ApiException('Unexpected response format.');
  }

  static Future<Map<String, dynamic>> getJson(String path) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl$path'),
      headers: _jsonHeaders,
    );

    if (response.statusCode == 401) {
      _handleUnauthorized(response.statusCode);
      throw const ApiException(
          'Your session has expired. Please sign in again.');
    }

    if (response.statusCode != 200) {
      throw ApiException('Failed to load $path (${response.statusCode})');
    }

    final decoded =
        response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    return decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'data': decoded};
  }

  static Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl$path'),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode == 401) {
      _handleUnauthorized(response.statusCode);
      throw const ApiException(
          'Your session has expired. Please sign in again.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message is String && message.isNotEmpty) {
          throw ApiException(message, statusCode: response.statusCode);
        }

        final errors = decoded['errors'];
        if (errors is List && errors.isNotEmpty) {
          final firstError = errors.first;
          if (firstError is Map<String, dynamic>) {
            final errorMessage = firstError['msg'];
            if (errorMessage is String && errorMessage.isNotEmpty) {
              throw ApiException(errorMessage, statusCode: response.statusCode);
            }
          }
        }
      }

      throw ApiException(
        'Request failed (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  static Future<Map<String, dynamic>> patchJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl$path'),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode == 401) {
      _handleUnauthorized(response.statusCode);
      throw const ApiException(
          'Your session has expired. Please sign in again.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message'] ?? decoded['error']
          : null;
      throw ApiException(
        message is String && message.isNotEmpty
            ? message
            : 'Request failed (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  static Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode == 401) {
      _handleUnauthorized(response.statusCode);
      throw const ApiException(
          'Your session has expired. Please sign in again.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message is String && message.isNotEmpty) {
          throw ApiException(message, statusCode: response.statusCode);
        }

        final errors = decoded['errors'];
        if (errors is List && errors.isNotEmpty) {
          final firstError = errors.first;
          if (firstError is Map<String, dynamic>) {
            final errorMessage = firstError['msg'];
            if (errorMessage is String && errorMessage.isNotEmpty) {
              throw ApiException(errorMessage, statusCode: response.statusCode);
            }
          }
        }
      }

      throw ApiException(
        'Request failed (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  static Future<Map<String, dynamic>> postMultipart(
    String path,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final request = http.MultipartRequest('POST', uri);
    if (AppConfig.current.tenantId.trim().isNotEmpty) {
      request.headers['X-Tenant-ID'] = AppConfig.current.tenantId.trim();
    }
    if (hasAuthToken) {
      request.headers['Authorization'] = 'Bearer $_authToken';
    }
    request.fields.addAll(fields);
    request.files.addAll(files);

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();
    final decoded = responseBody.isEmpty ? null : jsonDecode(responseBody);

    if (streamedResponse.statusCode == 401) {
      _handleUnauthorized(streamedResponse.statusCode);
      throw const ApiException(
          'Your session has expired. Please sign in again.');
    }

    if (streamedResponse.statusCode < 200 ||
        streamedResponse.statusCode >= 300) {
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message is String && message.isNotEmpty) {
          throw ApiException(message, statusCode: streamedResponse.statusCode);
        }
      }
      throw ApiException(
        'Multipart request failed (${streamedResponse.statusCode}).',
        statusCode: streamedResponse.statusCode,
      );
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  static Future<Map<String, dynamic>> putMultipart(
    String path,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final request = http.MultipartRequest('PUT', uri);
    if (AppConfig.current.tenantId.trim().isNotEmpty) {
      request.headers['X-Tenant-ID'] = AppConfig.current.tenantId.trim();
    }
    if (hasAuthToken) {
      request.headers['Authorization'] = 'Bearer $_authToken';
    }
    request.fields.addAll(fields);
    request.files.addAll(files);

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();
    final decoded = responseBody.isEmpty ? null : jsonDecode(responseBody);

    if (streamedResponse.statusCode == 401) {
      _handleUnauthorized(streamedResponse.statusCode);
      throw const ApiException(
          'Your session has expired. Please sign in again.');
    }

    if (streamedResponse.statusCode < 200 ||
        streamedResponse.statusCode >= 300) {
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message is String && message.isNotEmpty) {
          throw ApiException(message, statusCode: streamedResponse.statusCode);
        }
      }
      throw ApiException(
        'Multipart request failed (${streamedResponse.statusCode}).',
        statusCode: streamedResponse.statusCode,
      );
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  static Future<void> delete(String path) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl$path'),
      headers: _jsonHeaders,
    );

    if (response.statusCode == 401) {
      _handleUnauthorized(response.statusCode);
      throw const ApiException(
          'Your session has expired. Please sign in again.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Delete failed (${response.statusCode}).',
          statusCode: response.statusCode);
    }
  }
}
