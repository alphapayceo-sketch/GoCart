import 'package:shop/config/app_config.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/api_client.dart';

abstract class WishlistRepository {
  Future<List<ProductModel>> getWishlist();
  Future<void> addToWishlist(String productId);
  Future<void> removeFromWishlist(String productId);
}

class RemoteWishlistRepository implements WishlistRepository {
  @override
  Future<List<ProductModel>> getWishlist() async {
    if (!AppConfig.current.useDemoData) {
      try {
        final rawItems = await ApiClient.getList('/api/wishlist');
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
  Future<void> addToWishlist(String productId) async {
    await ApiClient.postJson('/api/wishlist', {'product_id': productId});
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    await ApiClient.delete('/api/wishlist/$productId');
  }
}
