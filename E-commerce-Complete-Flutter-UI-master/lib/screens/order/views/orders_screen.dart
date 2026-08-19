import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/order_repository.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static final OrderRepository _repository = RemoteOrderRepository();
  late final Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _repository.getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Unable to load orders right now.'),
              );
            }

            final orders = snapshot.data ?? const <Map<String, dynamic>>[];
            if (orders.isEmpty) {
              return const Center(child: Text('No orders available yet.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(defaultPadding),
              itemCount: orders.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: defaultPadding),
              itemBuilder: (context, index) {
                final order = orders[index];
                final items = order['items'] is List
                    ? (order['items'] as List)
                    : const <dynamic>[];
                final status = order['status']?.toString() ?? 'pending';
                final total =
                    num.tryParse(order['total_amount']?.toString() ?? '') ?? 0;
                return Card(
                  child: ExpansionTile(
                    title: Text('Order #${order['id'] ?? '-'}'),
                    subtitle: Text(status.toUpperCase()),
                    trailing: Text(formatCurrency(total.toDouble()),
                        style: Theme.of(context).textTheme.titleSmall),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            defaultPadding, 0, defaultPadding, defaultPadding),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_dateLabel(order['created_at']),
                                  style: const TextStyle(color: blackColor40)),
                              const SizedBox(height: 8),
                              ...items.map((item) => ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                        item['name']?.toString() ?? 'Product'),
                                    subtitle: Text(
                                        'Quantity: ${item['quantity'] ?? 0}'),
                                  )),
                              const SizedBox(height: 4),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _showOrderDetails(context, order),
                                icon: const Icon(Icons.receipt_long_outlined),
                                label: const Text('View details'),
                              ),
                            ]),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _dateLabel(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    return date == null
        ? 'Date unavailable'
        : 'Placed ${date.toLocal().toString().split(' ').first}';
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order #${order['id'] ?? '-'}',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Status: ${order['status'] ?? 'pending'}'),
              Text('Payment: ${order['payment_method'] ?? 'Not specified'}'),
              Text('Shipping: ${order['shipping_method'] ?? 'Not specified'}'),
              const SizedBox(height: 16),
            ]),
      ),
    );
  }
}
