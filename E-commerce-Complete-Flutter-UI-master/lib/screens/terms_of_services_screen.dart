import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class TermsOfServicesScreen extends StatelessWidget {
  const TermsOfServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms of Service"),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("1. Introduction", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 8),
            Text(
              "Welcome to our E-commerce app. By using our service, you agree to these terms. Please read them carefully.",
              style: TextStyle(color: blackColor40),
            ),
            SizedBox(height: 24),
            Text("2. Privacy Policy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 8),
            Text(
              "Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your personal information.",
              style: TextStyle(color: blackColor40),
            ),
            SizedBox(height: 24),
            Text("3. Account Security", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 8),
            Text(
              "You are responsible for maintaining the confidentiality of your account and password. You agree to notify us immediately of any unauthorized use.",
              style: TextStyle(color: blackColor40),
            ),
            SizedBox(height: 24),
            Text("4. Purchases", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 8),
            Text(
              "All purchases made through the app are subject to our return and refund policy. Prices are subject to change without notice.",
              style: TextStyle(color: blackColor40),
            ),
          ],
        ),
      ),
    );
  }
}
