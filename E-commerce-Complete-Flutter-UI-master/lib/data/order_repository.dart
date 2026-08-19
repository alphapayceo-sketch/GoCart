import 'package:shop/config/app_config.dart';
import 'package:shop/services/api_client.dart';

abstract class OrderRepository {
  Future<List<Map<String, dynamic>>> getOrders();
  Future<Map<String, dynamic>> createOrder(
      {required String shippingAddressId,
      String? shippingMethod,
      double? shippingAmount,
      String? paymentMethod,
      int pointsUsed = 0,
      String? promoCode,
      double promoDiscount = 0});
}

class RemoteOrderRepository implements OrderRepository {
  @override
  Future<Map<String, dynamic>> createOrder(
      {required String shippingAddressId,
      String? shippingMethod,
      double? shippingAmount,
      String? paymentMethod,
      int pointsUsed = 0,
      String? promoCode,
      double promoDiscount = 0}) {
    return ApiClient.postJson('/api/orders', {
      'shipping_address_id': shippingAddressId,
      if (shippingMethod != null) 'shipping_method': shippingMethod,
      if (shippingAmount != null) 'shipping_amount': shippingAmount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      'points_used': pointsUsed,
      if (promoCode != null) 'promo_code': promoCode,
      'promo_discount': promoDiscount,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getOrders() async {
    if (!AppConfig.current.useDemoData) {
      try {
        final rawOrders = await ApiClient.getList('/api/orders');
        return rawOrders
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      } catch (_) {
        return const [];
      }
    }

    return const [];
  }
}
