import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/admin_repository.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late Future<Map<String, dynamic>> _stats;

  @override
  void initState() {
    super.initState();
    _stats = AdminRepository.getStats();
  }

  Future<void> _reload() async {
    setState(() => _stats = AdminRepository.getStats());
    await _stats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin dashboard'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _stats,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: ElevatedButton(
                  onPressed: _reload,
                  child: Text('Failed to load dashboard: ${snapshot.error}'),
                ),
              );
            }
            final stats = snapshot.data ?? <String, dynamic>{};
            return ListView(
              children: [
                Wrap(
                  spacing: defaultPadding,
                  runSpacing: defaultPadding,
                  children: [
                    _StatCard(
                        label: 'Revenue',
                        value: '${stats['total_revenue'] ?? 0}'),
                    _StatCard(
                        label: 'Orders',
                        value: '${stats['total_orders'] ?? 0}'),
                    _StatCard(
                        label: 'Users', value: '${stats['total_users'] ?? 0}'),
                    _StatCard(
                        label: 'Products',
                        value: '${stats['total_products'] ?? 0}'),
                  ],
                ),
                const SizedBox(height: defaultPadding * 2),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, adminProductsScreenRoute),
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('View Products'),
                ),
                const SizedBox(height: defaultPadding),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                      context, adminCreateProductScreenRoute),
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Create Product'),
                ),
                const SizedBox(height: defaultPadding),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, adminCategoriesScreenRoute),
                  icon: const Icon(Icons.category_outlined),
                  label: const Text('Manage Categories'),
                ),
                const SizedBox(height: defaultPadding),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, adminMerchantsScreenRoute),
                  icon: const Icon(Icons.storefront_outlined),
                  label: const Text('Manage Merchants'),
                ),
                const SizedBox(height: defaultPadding),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, adminOrdersScreenRoute),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('Monitor Orders'),
                ),
                const SizedBox(height: defaultPadding),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, adminUsersScreenRoute),
                  icon: const Icon(Icons.people_outline),
                  label: const Text('Manage Users'),
                ),
                const SizedBox(height: defaultPadding),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, adminOperationsScreenRoute),
                  icon: const Icon(Icons.monitor_heart_outlined),
                  label: const Text('Operations Oversight'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
