import 'package:flutter/material.dart';

class TermsOfServicesScreen extends StatelessWidget {
  const TermsOfServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Services'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          'These Terms of Service govern your use of the GoCart mobile app and platform. By using the app, you agree to provide accurate information, use the service responsibly, and comply with local laws and marketplace policies. We may update these terms from time to time, and continued use of the service after changes means you accept the updated terms. You are responsible for keeping your login details secure and for any activity on your account. Orders, payments, and deliveries are subject to our policies, availability, and applicable law. We do not guarantee uninterrupted service and reserve the right to suspend or restrict access for misuse, fraud, or policy violations.',
        ),
      ),
    );
  }
}
