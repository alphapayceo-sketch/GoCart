import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io_client;
import 'package:shop/config/app_config.dart';

typedef NotificationListener = void Function(Map<String, dynamic> notification);

typedef OrderUpdateListener = void Function(Map<String, dynamic> orderUpdate);

class NotificationSocketService {
  NotificationSocketService._();

  static socket_io_client.Socket? _socket;
  static final List<NotificationListener> _notificationListeners = [];
  static final List<OrderUpdateListener> _orderUpdateListeners = [];
  static final List<Map<String, dynamic>> _receivedNotifications = [];
  static final ValueNotifier<int> notificationCount = ValueNotifier<int>(0);

  static List<Map<String, dynamic>> get receivedNotifications =>
      List.unmodifiable(_receivedNotifications);

  static void initialize() {
    if (_socket != null) return;

    final uri = AppConfig.current.baseUrl
        .replaceFirst(RegExp(r'^https?://'), 'http://');

    _socket = socket_io_client.io(
      uri,
      socket_io_client.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _socket?.on('connect', (_) {
      _socket?.emit('join_notifications');
    });

    _socket?.on('notification', (data) {
      if (data is Map<String, dynamic>) {
        _receivedNotifications.insert(0, data);
        notificationCount.value = _receivedNotifications.length;
        for (final listener in _notificationListeners) {
          listener(data);
        }
      }
    });

    _socket?.on('order_status_updated', (data) {
      if (data is Map<String, dynamic>) {
        _receivedNotifications.insert(0, {
          'title': 'Order update',
          'message':
              'Order #${data['orderId']} status changed to ${data['status']}.',
          'orderId': data['orderId'],
          'status': data['status'],
          'timestamp': DateTime.now().toIso8601String(),
        });
        notificationCount.value = _receivedNotifications.length;
        for (final listener in _orderUpdateListeners) {
          listener(data);
        }
      }
    });
  }

  static void subscribeToNotifications(NotificationListener listener) {
    if (!_notificationListeners.contains(listener)) {
      _notificationListeners.add(listener);
    }
  }

  static void unsubscribeFromNotifications(NotificationListener listener) {
    _notificationListeners.remove(listener);
  }

  static void subscribeToOrderUpdates(OrderUpdateListener listener) {
    if (!_orderUpdateListeners.contains(listener)) {
      _orderUpdateListeners.add(listener);
    }
  }

  static void unsubscribeFromOrderUpdates(OrderUpdateListener listener) {
    _orderUpdateListeners.remove(listener);
  }

  static void dispose() {
    _socket?.disconnect();
    _socket?.destroy();
    _socket = null;
    _notificationListeners.clear();
    _orderUpdateListeners.clear();
  }
}
