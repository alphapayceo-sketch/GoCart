import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shop/services/api_client.dart';

class UserRepository {
  const UserRepository._();

  static Future<Map<String, dynamic>> fetchProfile() async {
    return ApiClient.getJson('/api/users/me');
  }

  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> payload,
  ) async {
    return ApiClient.putJson('/api/users/me', payload);
  }

  static Future<Map<String, dynamic>> uploadProfileImage(File file) async {
    final image = await http.MultipartFile.fromPath('image', file.path);
    return ApiClient.postMultipart(
        '/api/media/upload', <String, String>{}, [image]);
  }

  static Future<List<dynamic>> getAddresses() async {
    return ApiClient.getList('/api/users/me/addresses');
  }

  static Future<Map<String, dynamic>> addAddress(
    Map<String, dynamic> payload,
  ) async {
    return ApiClient.postJson('/api/users/me/addresses', payload);
  }

  static Future<void> deleteAddress(String id) async {
    await ApiClient.delete('/api/users/me/addresses/$id');
  }

  static Future<List<dynamic>> getFollowedStores() async {
    return ApiClient.getList('/api/stores/follows');
  }

  static Future<void> followStore(String brandName) async {
    await ApiClient.postJson('/api/stores/follows', {'brand_name': brandName});
  }

  static Future<void> unfollowStore(String brandName) async {
    await ApiClient.delete(
        '/api/stores/follows/${Uri.encodeComponent(brandName)}');
  }
}
