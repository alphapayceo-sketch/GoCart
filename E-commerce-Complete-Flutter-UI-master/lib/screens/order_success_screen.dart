import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: successColor),
              const SizedBox(height: defaultPadding),
              Text("Order Successful!", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text(
                "Your order has been placed successfully. You will receive an email confirmation shortly.",
                textAlign: TextAlign.center,
                style: TextStyle(color: blackColor40),
              ),
              const SizedBox(height: defaultPadding * 2),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text("Back to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
