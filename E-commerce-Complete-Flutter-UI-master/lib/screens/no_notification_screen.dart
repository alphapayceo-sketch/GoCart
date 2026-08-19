import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class NoNotificationScreen extends StatelessWidget {
  const NoNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 64, color: blackColor20),
            const SizedBox(height: 16),
            const Text("No notifications yet", style: TextStyle(color: blackColor40)),
          ],
        ),
      ),
    );
  }
}
