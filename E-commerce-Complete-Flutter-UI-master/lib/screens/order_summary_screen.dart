import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/order_repository.dart';
import 'package:shop/data/payment_repository.dart';
import 'package:shop/data/user_repository.dart';
import 'package:shop/data/wallet_repository.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/shipping_methods_screen.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen(
      {super.key, this.products = const [], this.selection});

  final List<ProductModel> products;
  final CheckoutSelection? selection;

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  final OrderRepository _orderRepository = RemoteOrderRepository();
  final PaymentRepository _paymentRepository = RemotePaymentRepository();
  final WalletRepository _walletRepository = RemoteWalletRepository();
  late final Future<List<dynamic>> _addressesFuture;
  bool _placingOrder = false;
  int _availablePoints = 0;
  bool _useShopCash = false;

  @override
  void initState() {
    super.initState();
    _addressesFuture = UserRepository.getAddresses();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final wallet = await _walletRepository.getWallet();
    if (mounted)
      setState(
          () => _availablePoints = (wallet['balance'] as num?)?.toInt() ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _addressesFuture,
      builder: (context, snapshot) {
        final selection = widget.selection;
        final products = selection?.products ?? widget.products;
        final addresses = snapshot.data ?? const <dynamic>[];
        final address =
            addresses.whereType<Map>().cast<Map<String, dynamic>>().firstWhere(
                  (item) => item['is_default'] == true,
                  orElse: () => addresses.isNotEmpty && addresses.first is Map
                      ? Map<String, dynamic>.from(addresses.first as Map)
                      : <String, dynamic>{},
                );
        final subtotal = products.fold<double>(
            0,
            (sum, product) =>
                sum +
                (product.priceAfetDiscount ?? product.price) *
                    (product.cartQuantity ?? 1));
        final shipping = selection?.shippingPrice ?? 5.0;
        final discount = _useShopCash ? _availablePoints.toDouble() : 0.0;
        final promoDiscount = selection?.promoDiscount ?? 0;
        final total = (subtotal + shipping - discount - promoDiscount)
            .clamp(0.0, double.infinity);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Order Summary'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipping Address',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatAddress(address),
                  style: const TextStyle(color: blackColor40),
                ),
                const Divider(height: 32),
                Text(
                  'Payment Method: ${selection?.paymentMethod ?? 'Credit Card'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(selection?.paymentMethod ?? 'Credit Card',
                    style: const TextStyle(color: blackColor40)),
                const Divider(height: 32),
                Text(
                  'Order Totals',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildPriceRow('Subtotal', subtotal),
                _buildPriceRow('Shipping', shipping),
                if (_availablePoints > 0)
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Use Shop Cash ($_availablePoints available)'),
                        Switch.adaptive(
                          value: _useShopCash,
                          onChanged: (value) =>
                              setState(() => _useShopCash = value),
                        ),
                      ]),
                if (_useShopCash)
                  _buildPriceRow('Shop Cash', -_availablePoints.toDouble()),
                if (promoDiscount > 0) _buildPriceRow('Promo', -promoDiscount),
                const Divider(height: 32),
                _buildPriceRow('Total', total, isTotal: true),
                const Spacer(),
                ElevatedButton(
                  onPressed: _placingOrder || address['id'] == null
                      ? null
                      : () => _placeOrder(address['id'].toString(), selection),
                  child: const Text('Place Order'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatAddress(Map<String, dynamic> address) {
    if (address.isEmpty) return 'Add a delivery address before checkout.';
    return [
      address['address_line1'],
      address['address_line2'],
      address['city'],
      address['state'],
      address['postal_code'],
      address['country']
    ].whereType<String>().where((part) => part.isNotEmpty).join(', ');
  }

  Future<void> _placeOrder(
      String addressId, CheckoutSelection? selection) async {
    setState(() => _placingOrder = true);
    try {
      final orderResponse = await _orderRepository.createOrder(
        shippingAddressId: addressId,
        shippingMethod: selection?.shippingMethod,
        shippingAmount: selection?.shippingPrice,
        paymentMethod: selection?.paymentMethod,
        pointsUsed:
            _useShopCash ? _availablePoints : (selection?.pointsUsed ?? 0),
        promoCode: selection?.promoCode,
        promoDiscount: selection?.promoDiscount ?? 0,
      );
      final paymentMethod = selection?.paymentMethod ?? 'Credit Card';
      if (paymentMethod == 'MTN Momo') {
        final order = orderResponse['order'];
        final orderId = order is Map ? order['id']?.toString() : null;
        final orderTotal =
            order is Map ? (order['total_amount'] as num?)?.toDouble() : null;
        final mobile = selection?.mobileNumber?.trim();
        if (orderId == null ||
            orderTotal == null ||
            mobile == null ||
            mobile.isEmpty) {
          throw Exception(
              'The order was created but payment details are incomplete.');
        }
        final paymentResponse = await _paymentRepository.initiateMomo(
          mobile: mobile,
          amountCents: (orderTotal * 100).round(),
          externalRef: orderId,
        );
        final result = paymentResponse['result'];
        final status = result is Map ? result['status']?.toString() : null;
        if (status != 'initiated' && status != 'timeout') {
          throw Exception('MTN MoMo payment could not be initiated.');
        }
      } else {
        throw Exception(
            'Credit card payments are not available yet. Select MTN Momo.');
      }
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(thanksForOrderScreenRoute);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _placingOrder = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Widget _buildPriceRow(String label, double price, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            formatCurrency(price),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? primaryColor : blackColor,
            ),
          ),
        ],
      ),
    );
  }
}
