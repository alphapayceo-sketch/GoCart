import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';

class ShippingMethodsScreen extends StatefulWidget {
  const ShippingMethodsScreen(
      {super.key,
      this.products = const [],
      this.promoCode,
      this.promoDiscount = 0});

  final List<ProductModel> products;
  final String? promoCode;
  final double promoDiscount;

  @override
  State<ShippingMethodsScreen> createState() => _ShippingMethodsScreenState();
}

class CheckoutSelection {
  const CheckoutSelection(
      {required this.products,
      required this.shippingMethod,
      required this.shippingPrice,
      this.paymentMethod = 'Credit Card',
      this.pointsUsed = 0,
      this.mobileNumber,
      this.promoCode,
      this.promoDiscount = 0});

  final List<ProductModel> products;
  final String shippingMethod;
  final double shippingPrice;
  final String paymentMethod;
  final int pointsUsed;
  final String? mobileNumber;
  final String? promoCode;
  final double promoDiscount;

  CheckoutSelection copyWith(
          {String? paymentMethod,
          int? pointsUsed,
          String? mobileNumber,
          String? promoCode,
          double? promoDiscount}) =>
      CheckoutSelection(
        products: products,
        shippingMethod: shippingMethod,
        shippingPrice: shippingPrice,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        pointsUsed: pointsUsed ?? this.pointsUsed,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        promoCode: promoCode ?? this.promoCode,
        promoDiscount: promoDiscount ?? this.promoDiscount,
      );
}

class _ShippingMethodsScreenState extends State<ShippingMethodsScreen> {
  final List<_ShippingOption> _options = const [
    _ShippingOption('Standard', '5-7 business days', 5.00),
    _ShippingOption('Express', '2-3 business days', 15.00),
    _ShippingOption('Next Day', '1 business day', 25.00),
  ];

  String selectedMethod = 'Standard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipping Methods'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            ..._options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: defaultPadding),
                child: _buildMethodTile(
                  option.title,
                  option.subtitle,
                  option.price,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(paymentMethodScreenRoute,
                    arguments: CheckoutSelection(
                      products: widget.products,
                      shippingMethod: selectedMethod,
                      shippingPrice: _options
                          .firstWhere(
                              (option) => option.title == selectedMethod)
                          .price,
                      promoCode: widget.promoCode,
                      promoDiscount: widget.promoDiscount,
                    ));
              },
              child: const Text('Continue to Payment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile(String title, String subtitle, double price) {
    final isSelected = selectedMethod == title;

    return GestureDetector(
      onTap: () => setState(() => selectedMethod = title),
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? primaryColor : blackColor10,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(defaultBorderRadious),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle, style: const TextStyle(color: blackColor40)),
                ],
              ),
            ),
            Text(
              formatCurrency(price),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShippingOption {
  const _ShippingOption(this.title, this.subtitle, this.price);

  final String title;
  final String subtitle;
  final double price;
}
