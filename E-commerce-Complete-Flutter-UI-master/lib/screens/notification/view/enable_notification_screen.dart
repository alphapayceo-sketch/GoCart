import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class EnableNotificationScreen extends StatelessWidget {
  const EnableNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_active,
                size: 88, color: primaryColor),
            const SizedBox(height: defaultPadding * 2),
            Text(
              'Enable notifications',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: defaultPadding),
            const Text(
              'Get updates on your orders, sale alerts, and order status changes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: blackColor40),
            ),
            const SizedBox(height: defaultPadding * 2),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('notifications');
              },
              child: const Text('Enable notifications'),
            ),
            const SizedBox(height: defaultPadding),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not now'),
            ),
          ],
        ),
      ),
    );
  }
}
