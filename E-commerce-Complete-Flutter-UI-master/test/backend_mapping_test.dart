import 'package:flutter_test/flutter_test.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/auth_service.dart';

void main() {
  group('backend mapping', () {
    test('maps product payloads into the UI model', () {
      final product = ProductModel.fromBackendJson({
        'id': 1,
        'name': 'Classic Sneakers',
        'brand_name': 'Nike',
        'price': '59.99',
        'price_after_discount': '49.99',
        'image_urls': ['https://example.com/shoe.png'],
      });

      expect(product.title, 'Classic Sneakers');
      expect(product.brandName, 'Nike');
      expect(product.price, 59.99);
      expect(product.priceAfetDiscount, 49.99);
      expect(product.image, 'https://example.com/shoe.png');
    });

    test('maps category payloads into the UI model', () {
      final category = CategoryModel.fromBackendJson({
        'id': 3,
        'name': 'Accessories',
        'image_url': 'https://example.com/accessories.png',
        'sub_categories': [
          {'id': 4, 'name': 'Bags'}
        ],
      });

      expect(category.title, 'Accessories');
      expect(category.image, 'https://example.com/accessories.png');
      expect(category.subCategories, hasLength(1));
      expect(category.subCategories!.first.title, 'Bags');
    });

    test('extracts bearer token from auth responses', () {
      final token = AuthService.extractTokenFromResponse({
        'data': {
          'user': {'email': 'demo@example.com'},
          'token': 'Bearer abc123xyz',
        },
      });

      expect(token, 'abc123xyz');
    });
  });
}
