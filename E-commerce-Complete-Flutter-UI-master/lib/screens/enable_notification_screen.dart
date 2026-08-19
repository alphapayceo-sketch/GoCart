import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';

class EnableNotificationScreen extends StatelessWidget {
  const EnableNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_active,
                size: 100, color: primaryColor),
            const SizedBox(height: defaultPadding * 2),
            Text(
              "Enable Notifications",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: defaultPadding),
            const Text(
              "Get updates about your orders, personalized offers, and new arrivals instantly.",
              textAlign: TextAlign.center,
              style: TextStyle(color: blackColor40),
            ),
            const SizedBox(height: defaultPadding * 3),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pushReplacementNamed(notificationsScreenRoute);
              },
              child: const Text("Enable Notifications"),
            ),
            const SizedBox(height: defaultPadding),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Not Now", style: TextStyle(color: blackColor40)),
            ),
          ],
        ),
      ),
    );
  }
}
