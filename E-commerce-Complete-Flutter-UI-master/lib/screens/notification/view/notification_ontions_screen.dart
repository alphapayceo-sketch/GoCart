import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class NotificationOptionsScreen extends StatefulWidget {
  const NotificationOptionsScreen({super.key});

  @override
  State<NotificationOptionsScreen> createState() =>
      _NotificationOptionsScreenState();
}

class _NotificationOptionsScreenState extends State<NotificationOptionsScreen> {
  bool pushNotifications = true;
  bool orderUpdates = true;
  bool promotions = false;
  bool reminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification settings')),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          _ToggleRow(
            title: 'Push notifications',
            subtitle: 'Receive updates directly on your device.',
            value: pushNotifications,
            onChanged: (value) => setState(() => pushNotifications = value),
          ),
          _ToggleRow(
            title: 'Order updates',
            subtitle: 'Shipment and delivery status notifications.',
            value: orderUpdates,
            onChanged: (value) => setState(() => orderUpdates = value),
          ),
          _ToggleRow(
            title: 'Promotions',
            subtitle: 'Promotional offers and featured deals.',
            value: promotions,
            onChanged: (value) => setState(() => promotions = value),
          ),
          _ToggleRow(
            title: 'Reminders',
            subtitle: 'Suggested reorders or saved item reminders.',
            value: reminders,
            onChanged: (value) => setState(() => reminders = value),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: defaultPadding),
      padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding, vertical: defaultPadding / 2),
      decoration: BoxDecoration(
        color: blackColor5,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: blackColor40)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
