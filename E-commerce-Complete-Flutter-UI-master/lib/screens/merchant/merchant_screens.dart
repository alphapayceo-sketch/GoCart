import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop/config/app_config.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/merchant_repository.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/auth_service.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() =>
      _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  late Future<Map<String, dynamic>> _dashboard;

  @override
  void initState() {
    super.initState();
    _dashboard = MerchantRepository.getDashboard();
  }

  void _refresh() => setState(() {
        _dashboard = MerchantRepository.getDashboard();
      });

  @override
  Widget build(BuildContext context) {
    return MerchantPage(
      title: 'Merchant dashboard',
      actions: [
        IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))
      ],
      child: FutureBuilder<Map<String, dynamic>>(
        future: _dashboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError)
            return ErrorState(
                error: snapshot.error.toString(), onRetry: _refresh);
          final data = snapshot.data ?? <String, dynamic>{};
          final dashboard = _map(data['dashboard']);
          final health = _map(data['inventoryHealth']);
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text('Welcome back, ${AuthService.currentUserName}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: defaultPadding),
                Wrap(
                    spacing: defaultPadding,
                    runSpacing: defaultPadding,
                    children: [
                      MetricCard(
                          label: 'Revenue',
                          value: _money(dashboard['totalRevenue'])),
                      MetricCard(
                          label: 'Orders',
                          value: _number(dashboard['totalOrders'])),
                      MetricCard(
                          label: 'Pending fulfillment',
                          value: _number(dashboard['pendingFulfillment'])),
                      MetricCard(
                          label: 'Low stock',
                          value: _number(dashboard['lowStockItems'])),
                    ]),
                const SizedBox(height: defaultPadding * 1.5),
                SectionTitle(title: 'Inventory health'),
                Card(
                    child: Column(children: [
                  HealthRow(
                      label: 'Healthy',
                      value: _number(health['healthy']),
                      color: Colors.green),
                  HealthRow(
                      label: 'Low stock',
                      value: _number(health['lowStock']),
                      color: Colors.orange),
                  HealthRow(
                      label: 'Out of stock',
                      value: _number(health['outOfStock']),
                      color: Colors.red),
                ])),
                const SizedBox(height: defaultPadding),
                SectionTitle(title: 'Operations'),
                _ActionTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'Inventory',
                    route: merchantInventoryScreenRoute),
                _ActionTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Orders',
                    route: merchantOrdersScreenRoute),
                _ActionTile(
                    icon: Icons.local_shipping_outlined,
                    title: 'Fulfillment',
                    route: merchantFulfillmentScreenRoute),
                _ActionTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Settlements',
                    route: merchantSettlementsScreenRoute),
                _ActionTile(
                    icon: Icons.storefront_outlined,
                    title: 'Store operations',
                    route: merchantStoreScreenRoute),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MerchantInventoryScreen extends StatefulWidget {
  const MerchantInventoryScreen({super.key});

  @override
  State<MerchantInventoryScreen> createState() =>
      _MerchantInventoryScreenState();
}

class _MerchantInventoryScreenState extends State<MerchantInventoryScreen> {
  late Future<List<Map<String, dynamic>>> _products;
  String? _selectedProduct;
  Map<String, dynamic>? _inventory;

  @override
  void initState() {
    super.initState();
    _products = MerchantRepository.getProducts();
  }

  Future<void> _loadInventory(String id) async {
    setState(() => _selectedProduct = id);
    try {
      final inventory = await MerchantRepository.getInventory(id);
      if (mounted) setState(() => _inventory = inventory);
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    }
  }

  Future<void> _adjust() async {
    final productId = _selectedProduct;
    if (productId == null) return;
    final quantityController = TextEditingController();
    final reasonController = TextEditingController(text: 'manual_adjustment');
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust stock'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity change')),
          TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason')),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Apply')),
        ],
      ),
    );
    final quantity = int.tryParse(quantityController.text);
    if (submitted != true || quantity == null || quantity == 0) return;
    try {
      await MerchantRepository.adjustStock(
          productId: productId,
          quantity: quantity,
          reason: reasonController.text.trim());
      await _loadInventory(productId);
      if (mounted) _showMessage('Stock updated');
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return MerchantPage(
      title: 'Inventory',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return ErrorState(
                error: snapshot.error.toString(),
                onRetry: () => setState(
                    () => _products = MerchantRepository.getProducts()));
          final products = snapshot.data ?? [];
          if (products.isEmpty)
            return const EmptyState(message: 'No products found');
          return ListView(children: [
            DropdownButtonFormField<String>(
              value: _selectedProduct,
              decoration: const InputDecoration(labelText: 'Product'),
              items: products.map((product) {
                final id = '${product['id']}';
                return DropdownMenuItem(
                    value: id, child: Text('${product['name'] ?? 'Unnamed'}'));
              }).toList(),
              onChanged: (id) {
                if (id != null) _loadInventory(id);
              },
            ),
            const SizedBox(height: defaultPadding),
            if (_inventory != null) ...[
              StockSummary(stock: _map(_inventory!['stock'])),
              const SizedBox(height: defaultPadding),
              FilledButton.icon(
                  onPressed: _adjust,
                  icon: const Icon(Icons.tune),
                  label: const Text('Adjust stock')),
              const SizedBox(height: defaultPadding),
              if ((_inventory!['variants'] as List?)?.isNotEmpty == true) ...[
                const SectionTitle(title: 'Variants'),
                ...((_inventory!['variants'] as List)
                    .whereType<Map<String, dynamic>>()
                    .map((variant) => ListTile(
                          title: Text(
                              '${variant['name'] ?? variant['sku'] ?? 'Variant'}'),
                          trailing: Text(_number(
                              _map(variant['stock'])['available'] ??
                                  variant['stock_quantity'])),
                        )))
              ],
            ] else
              const EmptyState(message: 'Select a product to inspect stock'),
          ]);
        },
      ),
    );
  }
}

class MerchantOrdersScreen extends StatefulWidget {
  const MerchantOrdersScreen({super.key});
  @override
  State<MerchantOrdersScreen> createState() => _MerchantOrdersScreenState();
}

class _MerchantOrdersScreenState extends State<MerchantOrdersScreen> {
  late Future<List<Map<String, dynamic>>> _orders;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _orders = MerchantRepository.getOrders();
  }

  @override
  Widget build(BuildContext context) => MerchantPage(
        title: 'Orders',
        actions: [
          IconButton(
              onPressed: () =>
                  setState(() => _orders = MerchantRepository.getOrders()),
              icon: const Icon(Icons.refresh))
        ],
        child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _orders,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError)
                return ErrorState(
                    error: snapshot.error.toString(),
                    onRetry: () => setState(
                        () => _orders = MerchantRepository.getOrders()));
              final allOrders = snapshot.data ?? [];
              final query = _searchQuery.trim().toLowerCase();
              final orders = allOrders.where((order) {
                if (query.isEmpty) return true;
                final id = '${order['id'] ?? ''}'.toLowerCase();
                final email = '${order['email'] ?? ''}'.toLowerCase();
                final status = '${order['status'] ?? ''}'.toLowerCase();
                return id.contains(query) ||
                    email.contains(query) ||
                    status.contains(query);
              }).toList();
              if (orders.isEmpty)
                return const EmptyState(message: 'No orders found');
              return Column(children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                      labelText: 'Search orders',
                      prefixIcon: Icon(Icons.search)),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: defaultPadding),
                Expanded(
                    child: ListView.separated(
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final id = '${order['id']}';
                          final customer =
                              '${order['first_name'] ?? ''} ${order['last_name'] ?? ''}'
                                  .trim();
                          return ListTile(
                            title: Text(
                                'Order ${id.substring(0, id.length > 8 ? 8 : id.length)}'),
                            subtitle: Text(
                                '${customer.isEmpty ? order['email'] ?? 'Customer' : customer}\n${order['status'] ?? 'pending'}'),
                            isThreeLine: true,
                            trailing: Text(_money(order['total_amount'])),
                            onTap: () => Navigator.pushNamed(
                              context,
                              merchantOrderDetailsScreenRoute,
                              arguments: order,
                            ),
                          );
                        })),
              ]);
            }),
      );
}

class MerchantFulfillmentScreen extends StatefulWidget {
  const MerchantFulfillmentScreen({super.key});
  @override
  State<MerchantFulfillmentScreen> createState() =>
      _MerchantFulfillmentScreenState();
}

class _MerchantFulfillmentScreenState extends State<MerchantFulfillmentScreen> {
  late Future<List<Map<String, dynamic>>> _orders;
  final statuses = const [
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled'
  ];
  @override
  void initState() {
    super.initState();
    _orders = MerchantRepository.getOrders();
  }

  Future<void> _update(String id, String status) async {
    try {
      await MerchantRepository.updateFulfillment(id, status);
      if (mounted) setState(() => _orders = MerchantRepository.getOrders());
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => MerchantPage(
      title: 'Fulfillment',
      child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _orders,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return ErrorState(
                  error: snapshot.error.toString(),
                  onRetry: () =>
                      setState(() => _orders = MerchantRepository.getOrders()));
            final orders = snapshot.data ?? [];
            if (orders.isEmpty)
              return const EmptyState(message: 'No orders need fulfillment');
            return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final current = '${order['status'] ?? 'pending'}';
                  final value =
                      statuses.contains(current) ? current : statuses.first;
                  return Card(
                      child: Padding(
                          padding: const EdgeInsets.all(defaultPadding),
                          child: Row(children: [
                            Expanded(
                                child: Text(
                                    'Order ${order['id']}\nCurrent status: $current')),
                            DropdownButton<String>(
                                value: value,
                                items: statuses
                                    .map((status) => DropdownMenuItem(
                                        value: status, child: Text(status)))
                                    .toList(),
                                onChanged: (status) {
                                  if (status != null && status != current)
                                    _update('${order['id']}', status);
                                })
                          ])));
                });
          }));
}

class MerchantSettlementsScreen extends StatefulWidget {
  const MerchantSettlementsScreen({super.key});
  @override
  State<MerchantSettlementsScreen> createState() =>
      _MerchantSettlementsScreenState();
}

class _MerchantSettlementsScreenState extends State<MerchantSettlementsScreen> {
  late Future<Map<String, dynamic>> _balance;
  late Future<List<Map<String, dynamic>>> _history;
  late Future<Map<String, dynamic>?> _destination;
  @override
  void initState() {
    super.initState();
    _balance = MerchantRepository.getBalance();
    _history = MerchantRepository.getSettlementHistory();
    _destination = MerchantRepository.getPayoutDestination();
  }

  Future<void> _configureDestination() async {
    final controller = TextEditingController();
    final identifier = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payout destination'),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(labelText: 'Masked account or wallet'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (identifier == null || identifier.isEmpty) return;
    try {
      await MerchantRepository.savePayoutDestination(
          maskedIdentifier: identifier);
      if (mounted) {
        setState(
            () => _destination = MerchantRepository.getPayoutDestination());
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payout destination saved')));
      }
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _requestSettlement(double available) async {
    final controller =
        TextEditingController(text: available.toStringAsFixed(2));
    final submitted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Request settlement'),
                content: TextField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Amount')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Request'))
                ]));
    final amount = double.tryParse(controller.text);
    if (submitted != true || amount == null || amount <= 0) return;
    try {
      await MerchantRepository.createSettlement(amount);
      if (mounted) {
        setState(() => _balance = MerchantRepository.getBalance());
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settlement requested')));
      }
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => MerchantPage(
      title: 'Settlements',
      child: FutureBuilder<Map<String, dynamic>>(
          future: _balance,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return ErrorState(
                  error: snapshot.error.toString(),
                  onRetry: () => setState(
                      () => _balance = MerchantRepository.getBalance()));
            final balance = _map((snapshot.data ?? {})['balance']);
            final available = _amount(balance['available']);
            return ListView(children: [
              Card(
                  child: Column(children: [
                BalanceRow(label: 'Available', value: available),
                BalanceRow(
                    label: 'Pending', value: _amount(balance['pending'])),
                BalanceRow(
                    label: 'Reserved', value: _amount(balance['reserved'])),
                BalanceRow(
                    label: 'Paid out', value: _amount(balance['paidOut']))
              ])),
              const SizedBox(height: defaultPadding),
              FilledButton.icon(
                  onPressed: available > 0
                      ? () => _requestSettlement(available)
                      : null,
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Request payout')),
              const SizedBox(height: defaultPadding),
              FutureBuilder<Map<String, dynamic>?>(
                future: _destination,
                builder: (context, destinationSnapshot) {
                  final destination = destinationSnapshot.data;
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.account_balance_outlined),
                      title: Text(
                          destination?['masked_identifier']?.toString() ??
                              'No payout destination configured'),
                      subtitle: const Text('Default payout destination'),
                      trailing: IconButton(
                          onPressed: _configureDestination,
                          icon: const Icon(Icons.edit)),
                    ),
                  );
                },
              ),
              const SizedBox(height: defaultPadding),
              const SectionTitle(title: 'Settlement history'),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _history,
                builder: (context, historySnapshot) {
                  if (historySnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (historySnapshot.hasError) {
                    return ErrorState(
                        error: historySnapshot.error.toString(),
                        onRetry: () => setState(() => _history =
                            MerchantRepository.getSettlementHistory()));
                  }
                  final history = historySnapshot.data ?? [];
                  if (history.isEmpty)
                    return const EmptyState(message: 'No settlements found');
                  return Column(
                      children: history
                          .map((settlement) => ListTile(
                                title: Text(_money(settlement['amount'] ?? 0)),
                                subtitle: Text(settlement['payout_reference']
                                        ?.toString() ??
                                    'Settlement'),
                                trailing: Text(
                                    settlement['status']?.toString() ??
                                        'UNKNOWN'),
                              ))
                          .toList());
                },
              ),
            ]);
          }));
}

class MerchantOnboardingScreen extends StatefulWidget {
  const MerchantOnboardingScreen({super.key});

  @override
  State<MerchantOnboardingScreen> createState() =>
      _MerchantOnboardingScreenState();
}

class _MerchantOnboardingScreenState extends State<MerchantOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final profile = await MerchantRepository.getProfile();
      final kyc = profile['kyc_data'] is Map<String, dynamic>
          ? profile['kyc_data'] as Map<String, dynamic>
          : <String, dynamic>{};
      if (!mounted) return;
      _storeNameController.text = (kyc['store_name'] ?? '').toString();
      _businessNameController.text =
          (profile['business_name'] ?? '').toString();
      _emailController.text =
          (kyc['business_email'] ?? AuthService.currentUserEmail).toString();
      _phoneController.text = (kyc['business_phone'] ?? '').toString();
      _countryController.text = (kyc['country'] ?? '').toString();
    } catch (_) {
      if (mounted) {
        _emailController.text = AuthService.currentUserEmail;
      }
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final payload = <String, dynamic>{
        'business_name': _businessNameController.text.trim(),
        'status': 'pending',
        'kyc_data': {
          'store_name': _storeNameController.text.trim(),
          'business_email': _emailController.text.trim(),
          'business_phone': _phoneController.text.trim(),
          'country': _countryController.text.trim(),
        },
      };

      await MerchantRepository.upsertProfile(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merchant onboarding saved.')),
      );
      Navigator.pushNamed(context, merchantStoreProfileScreenRoute);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MerchantPage(
      title: 'Merchant onboarding',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text('Set up your selling profile',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: defaultPadding),
            TextFormField(
              controller: _storeNameController,
              decoration: const InputDecoration(labelText: 'Store name'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: defaultPadding),
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(labelText: 'Business name'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: defaultPadding),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Business email'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: defaultPadding),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Business phone'),
            ),
            const SizedBox(height: defaultPadding),
            TextFormField(
              controller: _countryController,
              decoration: const InputDecoration(labelText: 'Country'),
            ),
            const SizedBox(height: defaultPadding * 1.5),
            FilledButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: Icon(_isLoading
                  ? Icons.hourglass_top
                  : Icons.check_circle_outline),
              label: Text(_isLoading ? 'Saving...' : 'Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class MerchantStoreProfileScreen extends StatefulWidget {
  const MerchantStoreProfileScreen({super.key});

  @override
  State<MerchantStoreProfileScreen> createState() =>
      _MerchantStoreProfileScreenState();
}

class _MerchantStoreProfileScreenState
    extends State<MerchantStoreProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _deliveryController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final profile = await MerchantRepository.getProfile();
      final kyc = profile['kyc_data'] is Map<String, dynamic>
          ? profile['kyc_data'] as Map<String, dynamic>
          : <String, dynamic>{};
      if (!mounted) return;
      _businessNameController.text =
          (profile['business_name'] ?? '').toString();
      _descriptionController.text = (kyc['store_description'] ??
              'Selling premium products to your local market.')
          .toString();
      _addressController.text =
          (kyc['business_address'] ?? 'Main marketplace address').toString();
      _deliveryController.text =
          (kyc['delivery_promise'] ?? '2-5 business days').toString();
    } catch (_) {
      _businessNameController.text = AuthService.currentUserName;
      _descriptionController.text =
          'Selling premium products to your local market.';
      _addressController.text = 'Main marketplace address';
      _deliveryController.text = '2-5 business days';
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _deliveryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final payload = <String, dynamic>{
        'business_name': _businessNameController.text.trim(),
        'status': 'pending',
        'kyc_data': {
          'store_description': _descriptionController.text.trim(),
          'business_address': _addressController.text.trim(),
          'delivery_promise': _deliveryController.text.trim(),
        },
      };
      await MerchantRepository.upsertProfile(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store profile updated.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MerchantPage(
      title: 'Store profile',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text('Business & store details',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: defaultPadding),
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(labelText: 'Business name'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: defaultPadding),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Store description'),
            ),
            const SizedBox(height: defaultPadding),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Business address'),
            ),
            const SizedBox(height: defaultPadding),
            TextFormField(
              controller: _deliveryController,
              decoration: const InputDecoration(labelText: 'Delivery promise'),
            ),
            const SizedBox(height: defaultPadding * 1.5),
            FilledButton.icon(
              onPressed: _isLoading ? null : _save,
              icon:
                  Icon(_isLoading ? Icons.hourglass_top : Icons.save_outlined),
              label: Text(_isLoading ? 'Saving...' : 'Save profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class MerchantProductsScreen extends StatefulWidget {
  const MerchantProductsScreen({super.key});

  @override
  State<MerchantProductsScreen> createState() => _MerchantProductsScreenState();
}

class _MerchantProductsScreenState extends State<MerchantProductsScreen> {
  late Future<List<ProductModel>> _productsFuture;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  Future<List<ProductModel>> _loadProducts() async {
    final rows = await MerchantRepository.getProducts();
    return rows.map((item) => ProductModel.fromBackendJson(item)).toList();
  }

  Future<void> _reloadProducts() async {
    setState(() {
      _productsFuture = _loadProducts();
    });
    await _productsFuture;
  }

  Future<void> _deleteProduct(String id) async {
    await MerchantRepository.deleteProduct(id);
    await _reloadProducts();
  }

  Future<void> _confirmDelete(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product'),
        content: const Text(
            'This will remove the product from your merchant catalog.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true && product.id != null) {
      try {
        await _deleteProduct(product.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully.')),
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant products'),
        actions: [
          IconButton(
              onPressed: _reloadProducts, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, merchantProductCreateScreenRoute)
                    .then((_) => _reloadProducts()),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: FutureBuilder<List<ProductModel>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Failed to load products.'),
                const SizedBox(height: defaultPadding),
                Text(snapshot.error.toString()),
                const SizedBox(height: defaultPadding),
                ElevatedButton(
                    onPressed: _reloadProducts, child: const Text('Retry')),
              ]));
            }
            final allProducts = snapshot.data ?? [];
            final products = allProducts.where((product) {
              final query = _searchQuery.trim().toLowerCase();
              if (query.isEmpty) return true;
              return product.title.toLowerCase().contains(query) ||
                  product.brandName.toLowerCase().contains(query) ||
                  (product.categoryName ?? '').toLowerCase().contains(query);
            }).toList();
            if (products.isEmpty) {
              return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('No products found.'),
                const SizedBox(height: defaultPadding),
                ElevatedButton(
                    onPressed: _reloadProducts, child: const Text('Reload')),
              ]));
            }
            return Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search products',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: defaultPadding),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _reloadProducts,
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: defaultPadding / 2),
                          child: ListTile(
                            leading: SizedBox(
                              width: 64,
                              height: 64,
                              child: product.image.isNotEmpty
                                  ? Image.network(product.image,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, _, __) =>
                                          const Icon(Icons.image_not_supported,
                                              size: 32))
                                  : const Icon(Icons.image, size: 32),
                            ),
                            title: Text(product.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(product.brandName.isNotEmpty
                                    ? product.brandName
                                    : 'No brand provided'),
                                const SizedBox(height: 4),
                                if (product.stockQuantity != null)
                                  Text('Stock: ${product.stockQuantity}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(formatCurrency(product.price)),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    merchantProductEditScreenRoute,
                                    arguments: {
                                      'id': product.id,
                                      'name': product.title,
                                      'brand_name': product.brandName,
                                      'price': product.price,
                                      'price_after_discount':
                                          product.priceAfetDiscount,
                                      'discount_percent':
                                          product.dicountpercent,
                                      'category_id': product.categoryId,
                                      'stock_quantity': product.stockQuantity,
                                      'image_urls': product.imageUrls,
                                    },
                                  ).then((_) => _reloadProducts()),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _confirmDelete(product),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class MerchantCategoriesScreen extends StatefulWidget {
  const MerchantCategoriesScreen({super.key});

  @override
  State<MerchantCategoriesScreen> createState() =>
      _MerchantCategoriesScreenState();
}

class _MerchantCategoriesScreenState extends State<MerchantCategoriesScreen> {
  bool _isLoading = true;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await MerchantRepository.getCategories();
      if (!mounted) return;
      setState(() => _categories = categories);
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCategory(String id) async {
    try {
      await MerchantRepository.deleteCategory(id);
      await _loadCategories();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted successfully.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant categories'),
        actions: [
          IconButton(
            onPressed: () async {
              final name = await showDialog<String>(
                context: context,
                builder: (context) {
                  final controller = TextEditingController();
                  return AlertDialog(
                    title: const Text('New category'),
                    content: TextField(
                        controller: controller,
                        decoration:
                            const InputDecoration(labelText: 'Category name')),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () =>
                              Navigator.pop(context, controller.text.trim()),
                          child: const Text('Save')),
                    ],
                  );
                },
              );
              if (name != null && name.isNotEmpty) {
                await MerchantRepository.createCategory(name);
                await _loadCategories();
              }
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _categories.isEmpty
                ? const Center(child: Text('No categories found.'))
                : ListView.separated(
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return ListTile(
                        leading:
                            category.image != null && category.image!.isNotEmpty
                                ? Image.network(
                                    category.image!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported),
                                  )
                                : const Icon(Icons.category_outlined),
                        title: Text(category.title),
                        subtitle: Text(category.image ?? 'No image'),
                        onTap: () async {
                          if (category.id == null) return;
                          final result = await _showCategoryEditor(category);
                          if (result == null) return;
                          try {
                            await MerchantRepository.updateCategory(
                                category.id!, result['name'] as String);
                            final imagePath = result['imagePath'] as String?;
                            if (imagePath != null && imagePath.isNotEmpty) {
                              await MerchantRepository.updateCategoryImage(
                                  category.id!, File(imagePath));
                            }
                            await _loadCategories();
                          } catch (error) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())),
                            );
                          }
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            if (category.id != null)
                              _deleteCategory(category.id!);
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showCategoryEditor(
      CategoryModel category) async {
    final controller = TextEditingController(text: category.title);
    XFile? selectedImage;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Category name'),
              ),
              const SizedBox(height: defaultPadding),
              if (selectedImage != null)
                Image.file(File(selectedImage!.path),
                    height: 96, width: 96, fit: BoxFit.cover),
              TextButton.icon(
                onPressed: () async {
                  final image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (image != null)
                    setDialogState(() => selectedImage = image);
                },
                icon: const Icon(Icons.image_outlined),
                label: const Text('Choose image'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(context, {
                    'name': name,
                    'imagePath': selectedImage?.path,
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }
}

class MerchantCreateProductScreen extends StatefulWidget {
  const MerchantCreateProductScreen({super.key});

  @override
  State<MerchantCreateProductScreen> createState() =>
      _MerchantCreateProductScreenState();
}

class _MerchantCreateProductScreenState
    extends State<MerchantCreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _priceAfterDiscountController = TextEditingController();
  final _discountPercentController = TextEditingController();
  final _stockController = TextEditingController();
  final List<XFile> _selectedImages = [];
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _priceAfterDiscountController.dispose();
    _discountPercentController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await MerchantRepository.getCategories();
      if (!mounted) return;
      setState(() => _categories = categories);
    } catch (_) {
      if (!mounted) return;
    }
  }

  Future<void> _pickImages() async {
    final images = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (!mounted) return;
    setState(() {
      _selectedImages.clear();
      _selectedImages.addAll(images);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one image.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fields = <String, String>{
        'name': _nameController.text.trim(),
        'brand_name': _brandController.text.trim(),
        'price': _priceController.text.trim(),
        'price_after_discount': _priceAfterDiscountController.text.trim(),
        'discount_percent': _discountPercentController.text.trim(),
        'stock_quantity': _stockController.text.trim(),
      };
      if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
        fields['category_id'] = _selectedCategoryId!;
      }

      final imageFiles = _selectedImages.map((e) => File(e.path)).toList();
      await MerchantRepository.createProduct(fields, imageFiles);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product created successfully.')));
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create merchant product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter product name'
                    : null),
            const SizedBox(height: defaultPadding),
            TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand Name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter brand name'
                    : null),
            const SizedBox(height: defaultPadding),
            TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) => value == null ||
                        value.trim().isEmpty ||
                        double.tryParse(value) == null
                    ? 'Enter valid price'
                    : null),
            const SizedBox(height: defaultPadding),
            TextFormField(
                controller: _priceAfterDiscountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Price After Discount (optional)')),
            const SizedBox(height: defaultPadding),
            TextFormField(
                controller: _discountPercentController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Discount Percent')),
            const SizedBox(height: defaultPadding),
            TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock Quantity')),
            const SizedBox(height: defaultPadding),
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              items: _categories
                  .where((category) => category.id != null)
                  .map((category) => DropdownMenuItem(
                      value: category.id, child: Text(category.title)))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (value) => setState(() => _selectedCategoryId = value),
            ),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
                onPressed: _pickImages, child: const Text('Pick Images')),
            const SizedBox(height: defaultPadding),
            if (_selectedImages.isNotEmpty)
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedImages
                      .map((image) => Image.file(File(image.path),
                          width: 100, height: 100, fit: BoxFit.cover))
                      .toList()),
            const SizedBox(height: defaultPadding),
            FilledButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: Icon(_isLoading ? Icons.hourglass_top : Icons.save_alt),
                label: Text(_isLoading ? 'Saving...' : 'Create product')),
          ]),
        ),
      ),
    );
  }
}

class MerchantEditProductScreen extends StatefulWidget {
  const MerchantEditProductScreen({super.key, required this.product});

  final Map<String, dynamic> product;

  @override
  State<MerchantEditProductScreen> createState() =>
      _MerchantEditProductScreenState();
}

class _MerchantEditProductScreenState extends State<MerchantEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _priceController;
  late final TextEditingController _priceAfterDiscountController;
  late final TextEditingController _discountPercentController;
  late final TextEditingController _stockController;
  final List<XFile> _selectedImages = [];
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final product = ProductModel.fromBackendJson(widget.product);
    _nameController = TextEditingController(text: product.title);
    _brandController = TextEditingController(text: product.brandName);
    _priceController = TextEditingController(text: product.price.toString());
    _priceAfterDiscountController = TextEditingController(
        text: product.priceAfetDiscount?.toString() ?? '');
    _discountPercentController =
        TextEditingController(text: product.dicountpercent?.toString() ?? '');
    _stockController =
        TextEditingController(text: product.stockQuantity?.toString() ?? '');
    _selectedCategoryId = product.categoryId;
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _priceAfterDiscountController.dispose();
    _discountPercentController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await MerchantRepository.getCategories();
      if (!mounted) return;
      setState(() => _categories = categories);
    } catch (_) {
      if (!mounted) return;
    }
  }

  Future<void> _pickImages() async {
    final images = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (!mounted) return;
    setState(() {
      _selectedImages.clear();
      _selectedImages.addAll(images);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final fields = <String, String>{
        'name': _nameController.text.trim(),
        'brand_name': _brandController.text.trim(),
        'price': _priceController.text.trim(),
        'price_after_discount': _priceAfterDiscountController.text.trim(),
        'discount_percent': _discountPercentController.text.trim(),
        'stock_quantity': _stockController.text.trim(),
      };
      if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
        fields['category_id'] = _selectedCategoryId!;
      }
      final imageFiles = _selectedImages.map((e) => File(e.path)).toList();
      await MerchantRepository.updateProduct(
          widget.product['id']?.toString() ?? '', fields, imageFiles);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully.')));
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit merchant product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter product name'
                    : null),
            const SizedBox(height: defaultPadding),
            TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand Name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter brand name'
                    : null),
            const SizedBox(height: defaultPadding),
            TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) => value == null ||
                        value.trim().isEmpty ||
                        double.tryParse(value) == null
                    ? 'Enter valid price'
                    : null),
            const SizedBox(height: defaultPadding),
            TextFormField(
                controller: _priceAfterDiscountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Price After Discount (optional)')),
            const SizedBox(height: defaultPadding),
            TextFormField(
                controller: _discountPercentController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Discount Percent')),
            const SizedBox(height: defaultPadding),
            TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock Quantity')),
            const SizedBox(height: defaultPadding),
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              items: _categories
                  .where((category) => category.id != null)
                  .map((category) => DropdownMenuItem(
                      value: category.id, child: Text(category.title)))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (value) => setState(() => _selectedCategoryId = value),
            ),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
                onPressed: _pickImages, child: const Text('Pick Images')),
            const SizedBox(height: defaultPadding),
            if (_selectedImages.isNotEmpty)
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedImages
                      .map((image) => Image.file(File(image.path),
                          width: 100, height: 100, fit: BoxFit.cover))
                      .toList()),
            const SizedBox(height: defaultPadding),
            FilledButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: Icon(_isLoading ? Icons.hourglass_top : Icons.save_alt),
                label: Text(_isLoading ? 'Saving...' : 'Update product')),
          ]),
        ),
      ),
    );
  }
}

class MerchantOrderDetailsScreen extends StatefulWidget {
  const MerchantOrderDetailsScreen({super.key, required this.order});

  final Map<String, dynamic> order;

  @override
  State<MerchantOrderDetailsScreen> createState() =>
      _MerchantOrderDetailsScreenState();
}

class _MerchantOrderDetailsScreenState
    extends State<MerchantOrderDetailsScreen> {
  late Future<Map<String, dynamic>> _orderFuture;

  @override
  void initState() {
    super.initState();
    _orderFuture = _loadOrder();
  }

  Future<Map<String, dynamic>> _loadOrder() {
    final orderId = widget.order['id']?.toString();
    if (orderId == null || orderId.isEmpty) return Future.value(widget.order);
    return MerchantRepository.getOrderDetails(orderId);
  }

  @override
  Widget build(BuildContext context) {
    return MerchantPage(
      title: 'Order details',
      child: FutureBuilder<Map<String, dynamic>>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(
              error: snapshot.error.toString(),
              onRetry: () => setState(() => _orderFuture = _loadOrder()),
            );
          }

          final order = snapshot.data ?? widget.order;
          final items = order['items'] is List
              ? order['items'] as List
              : const <dynamic>[];
          final customer = (order['customer'] is Map<String, dynamic>)
              ? order['customer'] as Map<String, dynamic>
              : <String, dynamic>{};

          return ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ${order['id'] ?? '#'}',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Status: ${order['status'] ?? 'pending'}'),
                      Text('Customer: ${customer['first_name'] ?? ''} ${customer['last_name'] ?? ''}'
                              .trim()
                              .isEmpty
                          ? customer['email'] ?? 'Customer'
                          : '${customer['first_name'] ?? ''} ${customer['last_name'] ?? ''}'
                              .trim()),
                      Text('Total: ${_money(order['total_amount'] ?? 0)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding),
              const SectionTitle(title: 'Items'),
              if (items.isEmpty)
                const EmptyState(message: 'No items available')
              else
                ...items.map((item) {
                  final product = item is Map ? item : <String, dynamic>{};
                  return Card(
                    child: ListTile(
                      title: Text('${product['product_name'] ?? 'Product'}'),
                      subtitle: Text('Qty: ${product['quantity'] ?? 0}'),
                      trailing: Text(_money(product['price'] ?? 0)),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class MerchantStoreScreen extends StatelessWidget {
  const MerchantStoreScreen({super.key});
  @override
  Widget build(BuildContext context) => MerchantPage(
        title: 'Store operations',
        child: ListView(children: [
          Card(
              child: ListTile(
            leading: const Icon(Icons.storefront),
            title: Text(AuthService.currentUserName),
            subtitle: Text(
                'Tenant: ${AppConfig.current.tenantId.isEmpty ? 'default' : AppConfig.current.tenantId}'),
          )),
          const SizedBox(height: defaultPadding),
          const SectionTitle(title: 'Profile'),
          ActionTile(
              icon: Icons.badge_outlined,
              title: 'Onboarding',
              onTap: () =>
                  Navigator.pushNamed(context, merchantOnboardingScreenRoute)),
          ActionTile(
              icon: Icons.store_mall_directory_outlined,
              title: 'Store profile',
              onTap: () => Navigator.pushNamed(
                  context, merchantStoreProfileScreenRoute)),
          const SizedBox(height: defaultPadding),
          const SectionTitle(title: 'Catalog management'),
          ActionTile(
              icon: Icons.inventory_2_outlined,
              title: 'Manage products',
              onTap: () =>
                  Navigator.pushNamed(context, merchantProductsScreenRoute)),
          ActionTile(
              icon: Icons.add_box_outlined,
              title: 'Add product',
              onTap: () => Navigator.pushNamed(
                  context, merchantProductCreateScreenRoute)),
          ActionTile(
              icon: Icons.category_outlined,
              title: 'Manage categories',
              onTap: () =>
                  Navigator.pushNamed(context, merchantCategoriesScreenRoute)),
        ]),
      );
}

class MerchantPage extends StatelessWidget {
  const MerchantPage(
      {required this.title, required this.child, this.actions, super.key});
  final String title;
  final Widget child;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body:
          Padding(padding: const EdgeInsets.all(defaultPadding), child: child));
}

class MetricCard extends StatelessWidget {
  const MetricCard({required this.label, required this.value, super.key});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 160,
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label),
                    const SizedBox(height: 6),
                    Text(value,
                        style: Theme.of(context).textTheme.headlineSmall)
                  ]))));
}

class HealthRow extends StatelessWidget {
  const HealthRow(
      {required this.label,
      required this.value,
      required this.color,
      super.key});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => ListTile(
      leading: CircleAvatar(backgroundColor: color, radius: 6),
      title: Text(label),
      trailing: Text(value));
}

class StockSummary extends StatelessWidget {
  const StockSummary({required this.stock, super.key});
  final Map<String, dynamic> stock;
  @override
  Widget build(BuildContext context) => Card(
          child: Column(children: [
        BalanceRow(
            label: 'On hand',
            value: _amount(stock['on_hand_quantity'] ?? stock['onHand'])),
        BalanceRow(
            label: 'Available',
            value: _amount(stock['available'] ?? stock['available_quantity'])),
        BalanceRow(label: 'Status', value: '${stock['status'] ?? 'unknown'}')
      ]));
}

class BalanceRow extends StatelessWidget {
  const BalanceRow({required this.label, required this.value, super.key});
  final String label;
  final dynamic value;
  @override
  Widget build(BuildContext context) => ListTile(
      title: Text(label),
      trailing: Text(value is num ? _money(value) : '$value'));
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.title, super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding / 2),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium));
}

class ActionTile extends StatelessWidget {
  const ActionTile(
      {required this.icon,
      required this.title,
      required this.onTap,
      super.key});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
      child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap));
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.icon, required this.title, required this.route});
  final IconData icon;
  final String title;
  final String route;
  @override
  Widget build(BuildContext context) => ActionTile(
      icon: icon,
      title: title,
      onTap: () => Navigator.pushNamed(context, route));
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.message, super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(defaultPadding * 2),
          child: Text(message)));
}

class ErrorState extends StatelessWidget {
  const ErrorState({required this.error, required this.onRetry, super.key});
  final String error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(error, textAlign: TextAlign.center),
        const SizedBox(height: defaultPadding),
        OutlinedButton(onPressed: onRetry, child: const Text('Retry'))
      ]));
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};
String _number(dynamic value) => value == null ? '0' : '$value';
String _money(dynamic value) => '\$${_amount(value).toStringAsFixed(2)}';
double _amount(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
