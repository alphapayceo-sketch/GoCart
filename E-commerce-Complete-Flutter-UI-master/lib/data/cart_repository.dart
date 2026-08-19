import 'package:shop/config/app_config.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/api_client.dart';

abstract class CartRepository {
  Future<List<ProductModel>> getCartItems();
  Future<void> addToCart(
      {required String productId, int quantity, String? variantId});
  Future<void> updateCartItem(
      {required String cartItemId, required int quantity});
  Future<void> deleteCartItem(String cartItemId);
}

class RemoteCartRepository implements CartRepository {
  @override
  Future<List<ProductModel>> getCartItems() async {
    if (!AppConfig.current.useDemoData) {
      try {
        final cart = await ApiClient.getJson('/api/cart');
        final rawItems = cart['items'] is List
            ? cart['items'] as List<dynamic>
            : const <dynamic>[];
        return rawItems
            .map((item) =>
                ProductModel.fromBackendJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return const [];
      }
    }

    return const [];
  }

  @override
  Future<void> addToCart(
      {required String productId, int quantity = 1, String? variantId}) async {
    if (!AppConfig.current.useDemoData) {
      await ApiClient.postJson('/api/cart', {
        'product_id': productId,
        'quantity': quantity,
        if (variantId != null) 'variant_id': variantId,
      });
    }
  }

  @override
  Future<void> updateCartItem(
      {required String cartItemId, required int quantity}) async {
    if (!AppConfig.current.useDemoData) {
      await ApiClient.putJson('/api/cart/$cartItemId', {
        'quantity': quantity,
      });
    }
  }

  @override
  Future<void> deleteCartItem(String cartItemId) async {
    if (!AppConfig.current.useDemoData) {
      await ApiClient.delete('/api/cart/$cartItemId');
    }
  }
}
