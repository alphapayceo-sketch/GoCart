import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/cart_repository.dart';
import 'package:shop/data/promo_repository.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static final CartRepository _repository = RemoteCartRepository();
  late final Future<List<ProductModel>> _productsFuture;
  final TextEditingController _promoController = TextEditingController();
  final PromoRepository _promoRepository = const PromoRepository();
  double _promoDiscount = 0;
  String? _promoCode;
  bool _applyingPromo = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _productsFuture = _repository.getCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Unable to load cart items.'));
          }

          final products = snapshot.data!;
          if (products.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildCartItem(context, products[index], index);
                  },
                ),
              ),
              _buildPromoAndCheckout(context, products),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, ProductModel product, int index) {
    final price = product.priceAfetDiscount ?? product.price;

    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      child: Row(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: blackColor5,
              borderRadius: BorderRadius.circular(defaultBorderRadious),
            ),
            child: Image.network(product.image),
          ),
          const SizedBox(width: defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text("Backend cart item",
                    style: TextStyle(color: blackColor40)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatCurrency(price),
                        style: const TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        _buildQuantityBtn(Icons.remove,
                            () => _changeQuantity(product, index, -1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('${product.cartQuantity ?? 1}'),
                        ),
                        _buildQuantityBtn(Icons.add,
                            () => _changeQuantity(product, index, 1)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  tooltip: 'Remove item',
                  onPressed: () => _changeQuantity(
                      product, index, -(product.cartQuantity ?? 1)),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityBtn(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        side: const BorderSide(color: blackColor10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  Future<void> _changeQuantity(
      ProductModel product, int index, int change) async {
    final cartItemId = product.cartItemId;
    final quantity = (product.cartQuantity ?? 1) + change;
    try {
      if (cartItemId == null || cartItemId.isEmpty) return;
      if (quantity <= 0) {
        await _repository.deleteCartItem(cartItemId);
      } else {
        await _repository.updateCartItem(
            cartItemId: cartItemId, quantity: quantity);
      }
      if (!mounted) return;
      setState(() => _productsFuture = _repository.getCartItems());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not update your cart')));
      }
    }
  }

  Widget _buildPromoAndCheckout(
      BuildContext context, List<ProductModel> products) {
    final itemCount = products.fold<int>(
        0, (sum, product) => sum + (product.cartQuantity ?? 1));
    final total = products.fold<double>(
        0,
        (sum, product) =>
            sum +
            (product.priceAfetDiscount ?? product.price) *
                (product.cartQuantity ?? 1));

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    decoration: InputDecoration(
                      hintText: "Promo Code",
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _applyingPromo ? null : () => _applyPromo(total),
                  child: const Text("Apply"),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total ($itemCount items)",
                    style: const TextStyle(color: blackColor40)),
                Text(
                    formatCurrency(
                        (total - _promoDiscount).clamp(0, double.infinity)),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            if (_promoDiscount > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Promo $_promoCode: -${formatCurrency(_promoDiscount)}'),
              ),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(shippingMethodsScreenRoute, arguments: {
                  'products': products,
                  'promoCode': _promoCode,
                  'promoDiscount': _promoDiscount,
                });
              },
              child: const Text("Checkout"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyPromo(double total) async {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;
    setState(() => _applyingPromo = true);
    try {
      final response =
          await _promoRepository.applyPromo(code: code, orderTotal: total);
      final discount = num.tryParse(response['discountAmount']?.toString() ??
                  response['discount_amount']?.toString() ??
                  '')
              ?.toDouble() ??
          0;
      if (!mounted) return;
      setState(() {
        _promoDiscount = discount.clamp(0, total);
        _promoCode = code;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Promo code applied.')));
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _applyingPromo = false);
    }
  }
}
