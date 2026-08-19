import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/shipping_methods_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key, this.selection});

  final CheckoutSelection? selection;

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<_PaymentOption> _options = const [
    _PaymentOption('Credit Card', Icons.credit_card),
    _PaymentOption('MTN Momo', Icons.phone_iphone),
  ];

  String selectedPayment = 'Credit Card';
  late final TextEditingController _mobileController;

  @override
  void initState() {
    super.initState();
    selectedPayment = widget.selection?.paymentMethod ?? selectedPayment;
    _mobileController =
        TextEditingController(text: widget.selection?.mobileNumber);
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            ..._options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: defaultPadding),
                child: _buildPaymentTile(option.title, option.icon),
              ),
            ),
            if (selectedPayment == 'MTN Momo')
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'MTN mobile number',
                  hintText: 'e.g. 096xxxxxxx',
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (selectedPayment == 'Credit Card') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Credit card payments are not available yet. Select MTN Momo.')),
                  );
                  return;
                }
                if (_mobileController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Enter an MTN mobile number to continue.')),
                  );
                  return;
                }
                final selection = (widget.selection ??
                        const CheckoutSelection(
                          products: [],
                          shippingMethod: 'Standard',
                          shippingPrice: 5,
                        ))
                    .copyWith(
                  paymentMethod: selectedPayment,
                  mobileNumber: _mobileController.text.trim(),
                );
                Navigator.of(context)
                    .pushNamed(orderSummaryScreenRoute, arguments: selection);
              },
              child: const Text('Review Order'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile(String title, IconData icon) {
    final isSelected = selectedPayment == title;

    return GestureDetector(
      onTap: () => setState(() => selectedPayment = title),
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
            Icon(icon, color: isSelected ? primaryColor : blackColor40),
            const SizedBox(width: defaultPadding),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: primaryColor),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption {
  const _PaymentOption(this.title, this.icon);

  final String title;
  final IconData icon;
}
