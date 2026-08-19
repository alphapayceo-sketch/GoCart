import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shop/models/category_model.dart';
import 'package:shop/services/api_client.dart';

class MerchantRepository {
  MerchantRepository._();

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiClient.getJson('/api/merchant/profile');
    if (response['merchant'] is Map<String, dynamic>) {
      return response['merchant'] as Map<String, dynamic>;
    }
    return response;
  }

  static Future<Map<String, dynamic>> upsertProfile(
      Map<String, dynamic> payload) {
    return ApiClient.postJson('/api/merchant/profile', payload);
  }

  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> payload) {
    return ApiClient.putJson('/api/merchant/profile', payload);
  }

  static Future<Map<String, dynamic>> getDashboard() {
    return ApiClient.getJson('/api/merchant-analytics/dashboard');
  }

  static Future<Map<String, dynamic>> getStats() {
    return ApiClient.getJson('/api/merchant/stats');
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    final orders = await ApiClient.getList('/api/merchant/orders');
    return orders.whereType<Map<String, dynamic>>().toList();
  }

  static Future<List<Map<String, dynamic>>> getFilteredOrders({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final queryString = Uri(queryParameters: query).query;
    final decoded =
        await ApiClient.getJson('/api/merchant/orders/filter?$queryString');
    final items =
        decoded['items'] is List ? decoded['items'] as List : const <dynamic>[];
    return items.whereType<Map<String, dynamic>>().toList();
  }

  static Future<List<Map<String, dynamic>>> getProducts() async {
    final products = await ApiClient.getList('/api/merchant/products');
    return products.whereType<Map<String, dynamic>>().toList();
  }

  static Future<List<CategoryModel>> getCategories() async {
    final rawCategories = await ApiClient.getList('/api/merchant/categories');
    return rawCategories
        .map((item) =>
            CategoryModel.fromBackendJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, dynamic>> createCategory(
    String name, {
    String? imageUrl,
    String? svgSrc,
    String? parentId,
  }) async {
    final payload = <String, dynamic>{'name': name};
    if (imageUrl != null && imageUrl.isNotEmpty)
      payload['image_url'] = imageUrl;
    if (svgSrc != null && svgSrc.isNotEmpty) payload['svg_src'] = svgSrc;
    if (parentId != null && parentId.isNotEmpty)
      payload['parent_id'] = parentId;
    return ApiClient.postJson('/api/merchant/categories', payload);
  }

  static Future<void> deleteCategory(String id) async {
    await ApiClient.delete('/api/merchant/categories/$id');
  }

  static Future<Map<String, dynamic>> updateCategory(
    String id,
    String name, {
    String? imageUrl,
    String? svgSrc,
    String? parentId,
  }) {
    final payload = <String, dynamic>{'name': name};
    if (imageUrl != null && imageUrl.isNotEmpty)
      payload['image_url'] = imageUrl;
    if (svgSrc != null && svgSrc.isNotEmpty) payload['svg_src'] = svgSrc;
    if (parentId != null && parentId.isNotEmpty)
      payload['parent_id'] = parentId;
    return ApiClient.putJson('/api/merchant/categories/$id', payload);
  }

  static Future<Map<String, dynamic>> updateCategoryImage(
      String id, File image) async {
    final file = await http.MultipartFile.fromPath('image', image.path);
    return ApiClient.putMultipart(
        '/api/merchant/categories/$id/image', {}, [file]);
  }

  static Future<Map<String, dynamic>> createProduct(
    Map<String, String> fields,
    List<File> images,
  ) async {
    final files = <http.MultipartFile>[];
    for (final image in images) {
      files.add(await http.MultipartFile.fromPath('images', image.path));
    }
    return ApiClient.postMultipart('/api/merchant/products', fields, files);
  }

  static Future<Map<String, dynamic>> updateProduct(
    String id,
    Map<String, String> fields,
    List<File> images,
  ) async {
    final files = <http.MultipartFile>[];
    for (final image in images) {
      files.add(await http.MultipartFile.fromPath('images', image.path));
    }
    return ApiClient.putMultipart('/api/merchant/products/$id', fields, files);
  }

  static Future<void> deleteProduct(String id) async {
    await ApiClient.delete('/api/merchant/products/$id');
  }

  static Future<Map<String, dynamic>> getOrderDetails(String orderId) {
    return ApiClient.getJson('/api/merchant/orders/details/$orderId');
  }

  static Future<List<Map<String, dynamic>>> getSettlementHistory() async {
    final rows = await ApiClient.getList('/api/merchant/settlement-history');
    return rows.whereType<Map<String, dynamic>>().toList();
  }

  static Future<Map<String, dynamic>> getInventory(String productId) {
    return ApiClient.getJson('/api/inventory/products/$productId');
  }

  static Future<Map<String, dynamic>> adjustStock({
    required String productId,
    required int quantity,
    String? variantId,
    String reason = 'manual_adjustment',
  }) {
    return ApiClient.postJson('/api/inventory/adjust', {
      'product_id': productId,
      if (variantId != null && variantId.isNotEmpty) 'variant_id': variantId,
      'quantity': quantity,
      'reason': reason,
    });
  }

  static Future<Map<String, dynamic>> getFulfillment(String orderId) {
    return ApiClient.getJson('/api/fulfillment/orders/$orderId');
  }

  static Future<Map<String, dynamic>> updateFulfillment(
      String orderId, String status) {
    return ApiClient.putJson('/api/fulfillment/orders/$orderId/status', {
      'status': status,
    });
  }

  static Future<Map<String, dynamic>> getBalance() {
    return ApiClient.getJson('/api/merchant/settlements/balance');
  }

  static Future<Map<String, dynamic>> createSettlement(double amount) {
    return ApiClient.postJson('/api/merchant/settlements', {
      'amount': amount,
    });
  }

  static Future<Map<String, dynamic>?> getPayoutDestination() async {
    final response =
        await ApiClient.getJson('/api/merchant/settlements/payout-destination');
    return response['id'] == null ? null : response;
  }

  static Future<Map<String, dynamic>> savePayoutDestination({
    required String maskedIdentifier,
    String destinationType = 'bank',
    String provider = 'bank',
  }) {
    return ApiClient.postJson('/api/merchant/settlements/payout-destination', {
      'masked_identifier': maskedIdentifier,
      'destination_type': destinationType,
      'provider': provider,
    });
  }
}
