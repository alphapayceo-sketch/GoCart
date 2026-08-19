import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class NoNotificationScreen extends StatelessWidget {
  const NoNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_off_outlined,
                  size: 72, color: blackColor40),
              const SizedBox(height: defaultPadding),
              Text(
                'No notifications yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: defaultPadding / 2),
              const Text(
                'You will see your delivery and promo updates here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: blackColor40),
              ),
              const SizedBox(height: defaultPadding * 2),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('notification_options');
                },
                child: const Text('Manage notification settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
