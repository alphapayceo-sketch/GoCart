import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/admin_repository.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  late Future<List<Map<String, dynamic>>> _orders;

  @override
  void initState() {
    super.initState();
    _orders = AdminRepository.getOrders();
  }

  Future<void> _reload() async {
    setState(() => _orders = AdminRepository.getOrders());
    await _orders;
  }

  String _money(dynamic value) {
    final amount = value is num ? value : num.tryParse(value.toString()) ?? 0;
    return NumberFormat.currency(symbol: 'UGX', decimalDigits: 2)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor orders'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _orders,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: ElevatedButton(
                      onPressed: _reload,
                      child: Text('Failed to load orders: ${snapshot.error}')));
            }
            final orders = snapshot.data ?? [];
            if (orders.isEmpty)
              return const Center(child: Text('No orders found.'));
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView.separated(
                itemCount: orders.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final id = '${order['id'] ?? ''}';
                  final customer =
                      '${order['first_name'] ?? ''} ${order['last_name'] ?? ''}'
                          .trim();
                  return ListTile(
                    title: Text(
                        'Order ${id.length > 8 ? id.substring(0, 8) : id}'),
                    subtitle: Text(
                        '${customer.isEmpty ? order['email'] ?? 'Customer' : customer}\n${order['status'] ?? 'pending'}'),
                    isThreeLine: true,
                    trailing: Text(_money(order['total_amount'] ?? 0)),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
