import 'package:shop/services/api_client.dart';

abstract class PaymentRepository {
  Future<Map<String, dynamic>> initiateMomo({
    required String mobile,
    required int amountCents,
    required String externalRef,
  });
}

class RemotePaymentRepository implements PaymentRepository {
  @override
  Future<Map<String, dynamic>> initiateMomo({
    required String mobile,
    required int amountCents,
    required String externalRef,
  }) {
    return ApiClient.postJson('/api/momo/initiate', {
      'mobile': mobile,
      'amountCents': amountCents,
      'externalRef': externalRef,
      'orderId': externalRef,
    });
  }
}
