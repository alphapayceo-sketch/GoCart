import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/notification_socket_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final List<_NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = NotificationSocketService.receivedNotifications
        .map((data) => _NotificationItem.fromMap(data))
        .toList();
    NotificationSocketService.subscribeToNotifications(_onNotificationReceived);
  }

  @override
  void dispose() {
    NotificationSocketService.unsubscribeFromNotifications(
        _onNotificationReceived);
    super.dispose();
  }

  void _onNotificationReceived(Map<String, dynamic> notification) {
    setState(() {
      _notifications.insert(0, _NotificationItem.fromMap(notification));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/DotsV.svg',
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color ?? Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Text('No notifications yet'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(defaultPadding),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return ListTile(
                  title: Text(notification.title),
                  subtitle: Text(notification.message),
                  trailing: Text(
                    notification.status ?? '',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.message,
    this.orderId,
    this.status,
    required this.timestamp,
  });

  factory _NotificationItem.fromMap(Map<String, dynamic> map) {
    return _NotificationItem(
      title: map['title']?.toString() ?? 'Notification',
      message: map['message']?.toString() ?? '',
      orderId: map['orderId']?.toString(),
      status: map['status']?.toString(),
      timestamp:
          map['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  final String title;
  final String message;
  final String? orderId;
  final String? status;
  final String timestamp;
}
