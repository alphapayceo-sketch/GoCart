import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shop/models/category_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/api_client.dart';

class AdminRepository {
  AdminRepository._();

  static Future<List<Map<String, dynamic>>> getUsers() async {
    final rows = await ApiClient.getList('/api/admin/users');
    return rows.whereType<Map<String, dynamic>>().toList();
  }

  static Future<void> updateUserRole(String userId, String role) async {
    await ApiClient.patchJson('/api/admin/users/$userId/role', {'role': role});
  }

  static Future<void> updateUserStatus(String userId, bool deleted) async {
    await ApiClient.patchJson(
        '/api/admin/users/$userId/status', {'deleted': deleted});
  }

  static Future<Map<String, dynamic>> getOperations() {
    return ApiClient.getJson('/api/admin/operations');
  }

  static Future<void> updateShipmentStatus(String id, String status) async {
    await ApiClient.patchJson(
        '/api/admin/operations/shipments/$id/status', {'status': status});
  }

  static Future<void> processRefund(String id,
      {double? orderTotal, double? refundPercent}) async {
    await ApiClient.patchJson('/api/admin/operations/returns/$id/refund', {
      if (orderTotal != null) 'order_total': orderTotal,
      if (refundPercent != null) 'refund_percent': refundPercent,
    });
  }

  static Future<void> updateSettlementStatus(String id, String status) async {
    await ApiClient.patchJson(
        '/api/admin/operations/settlements/$id/status', {'status': status});
  }

  static Future<void> resolveFraudFlag(String id) async {
    await ApiClient.patchJson(
        '/api/admin/operations/fraud-flags/$id/resolve', {});
  }

  static Future<Map<String, dynamic>> getStats() {
    return ApiClient.getJson('/api/admin/stats');
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    final rows = await ApiClient.getList('/api/admin/orders');
    return rows.whereType<Map<String, dynamic>>().toList();
  }

  static Future<List<CategoryModel>> getCategories() async {
    final rawCategories = await ApiClient.getList('/api/products/categories');
    return rawCategories
        .map((item) =>
            CategoryModel.fromBackendJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<CategoryModel>> getAdminCategories() async {
    final rawCategories = await ApiClient.getList('/api/admin/categories');
    return rawCategories
        .map((item) =>
            CategoryModel.fromBackendJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, dynamic>> createProduct(
    Map<String, String> fields,
    List<File> images,
  ) async {
    final files = <http.MultipartFile>[];
    for (final image in images) {
      files.add(await http.MultipartFile.fromPath('images', image.path));
    }
    return ApiClient.postMultipart('/api/admin/products', fields, files);
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
    return ApiClient.putMultipart('/api/admin/products/$id', fields, files);
  }

  static Future<void> deleteProduct(String id) async {
    await ApiClient.delete('/api/admin/products/$id');
  }

  static Future<List<ProductModel>> getAdminProducts() async {
    final rawProducts = await ApiClient.getList('/api/admin/products');
    return rawProducts
        .map((item) =>
            ProductModel.fromBackendJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, dynamic>> createCategory(
    String name, {
    String? imageUrl,
    String? svgSrc,
    String? parentId,
  }) async {
    final payload = <String, dynamic>{'name': name};
    if (imageUrl != null && imageUrl.isNotEmpty) {
      payload['image_url'] = imageUrl;
    }
    if (svgSrc != null && svgSrc.isNotEmpty) {
      payload['svg_src'] = svgSrc;
    }
    if (parentId != null && parentId.isNotEmpty) {
      payload['parent_id'] = parentId;
    }

    return ApiClient.postJson('/api/admin/categories', payload);
  }

  static Future<void> deleteCategory(String id) async {
    await ApiClient.delete('/api/admin/categories/$id');
  }

  static Future<void> updateCategory(String id, String name) async {
    await ApiClient.putJson('/api/admin/categories/$id', {'name': name});
  }

  static Future<void> updateCategoryImage(String id, File image) async {
    final file = await http.MultipartFile.fromPath('image', image.path);
    await ApiClient.putMultipart('/api/admin/categories/$id/image', {}, [file]);
  }

  static Future<List<Map<String, dynamic>>> getMerchants() async {
    final rows = await ApiClient.getList('/api/admin/merchants');
    return rows.whereType<Map<String, dynamic>>().toList();
  }

  static Future<Map<String, dynamic>> updateMerchantStatus(
      String merchantId, String status) {
    return ApiClient.patchJson('/api/admin/merchants/$merchantId/status', {
      'status': status,
    });
  }
}
