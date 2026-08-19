import 'package:shop/services/api_client.dart';

class ReviewRepository {
  const ReviewRepository();

  Future<List<Map<String, dynamic>>> getReviews(String productId) async {
    final reviews = await ApiClient.getList('/api/products/$productId/reviews');
    return reviews
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> addReview({
    required String productId,
    required int rating,
    required String comment,
  }) {
    return ApiClient.postJson('/api/products/$productId/reviews', {
      'rating': rating,
      'comment': comment,
    });
  }
}
