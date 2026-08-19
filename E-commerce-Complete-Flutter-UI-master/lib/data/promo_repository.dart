import 'package:shop/services/api_client.dart';

class PromoRepository {
  const PromoRepository();

  Future<Map<String, dynamic>> applyPromo({
    required String code,
    required double orderTotal,
  }) {
    return ApiClient.postJson('/api/marketing/promo/apply', {
      'code': code,
      'orderTotal': orderTotal,
    });
  }
}
