import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/views/product_details_screen.dart';

void main() {
  testWidgets('Product details screen uses the selected product data',
      (tester) async {
    final product = ProductModel(
      id: 'prod_123',
      title: 'Aurora Overshirt',
      brandName: 'VELA',
      description: 'Water-resistant overshirt built for everyday layering.',
      price: 79.99,
      priceAfetDiscount: 64.99,
      dicountpercent: 19,
      imageUrls: ['https://example.com/image.jpg'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailsScreen(product: product),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(ProductInfo),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProductInfo), findsOneWidget);
    expect(find.text('VELA'), findsOneWidget);
    expect(find.text('Aurora Overshirt'), findsOneWidget);
    expect(
        find.textContaining(
            'Water-resistant overshirt built for everyday layering.'),
        findsOneWidget);
  });
}
