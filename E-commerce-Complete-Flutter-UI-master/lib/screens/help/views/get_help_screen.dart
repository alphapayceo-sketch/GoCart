import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class GetHelpScreen extends StatelessWidget {
  const GetHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      (
        'How do I track my order?',
        'You can view live updates in Orders from your profile.'
      ),
      (
        'Can I change my delivery address?',
        'Yes, update it from Addresses before checkout.'
      ),
      (
        'Where is my refund?',
        'Refunds usually appear within 5–7 business days.'
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Help'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support centre',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Need help with your order, account, or payment? Our team is here to assist you.',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Contact support'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Text(
            'FAQs',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: defaultPadding / 2),
          ...faqItems(context, faqs),
        ],
      ),
    );
  }

  List<Widget> faqItems(BuildContext context, List<(String, String)> faqs) {
    return faqs
        .map(
          (faq) => ExpansionTile(
            title: Text(faq.$1),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  defaultPadding,
                  0,
                  defaultPadding,
                  defaultPadding,
                ),
                child: Text(faq.$2),
              ),
            ],
          ),
        )
        .toList();
  }
}
