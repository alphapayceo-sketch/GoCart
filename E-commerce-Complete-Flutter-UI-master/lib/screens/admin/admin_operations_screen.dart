import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/admin_repository.dart';

class AdminOperationsScreen extends StatefulWidget {
  const AdminOperationsScreen({super.key});

  @override
  State<AdminOperationsScreen> createState() => _AdminOperationsScreenState();
}

class _AdminOperationsScreenState extends State<AdminOperationsScreen> {
  late Future<Map<String, dynamic>> _operations;

  @override
  void initState() {
    super.initState();
    _operations = AdminRepository.getOperations();
  }

  Future<void> _reload() async {
    setState(() => _operations = AdminRepository.getOperations());
    await _operations;
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
      await _reload();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action completed')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Operations oversight'), actions: [
        IconButton(onPressed: _reload, icon: const Icon(Icons.refresh))
      ]),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _operations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return Center(
                  child: ElevatedButton(
                      onPressed: _reload,
                      child: Text(
                          'Failed to load operations: ${snapshot.error}')));
            final data = snapshot.data ?? {};
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                children: [
                  _section('Fulfillment and shipments', data['shipments'], 'shipment'),
                  _section('Returns and refunds', data['returns'], 'return'),
                  _section('Fraud flags', data['fraudFlags'], 'fraud'),
                  _section('Audit logs', data['auditLogs'], null),
                  _section('Invoices', data['invoices'], null),
                  _section('Settlement reconciliation', data['settlements'], 'settlement'),
                  _section('Commission entries', data['commissions'], null),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _section(String title, dynamic rawItems, [String? actionType]) {
    final items = rawItems is List
        ? rawItems.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];
    return Card(
      child: ExpansionTile(
        title: Text(title),
        subtitle: Text('${items.length} records'),
        children: items.isEmpty
            ? [const ListTile(title: Text('No records found'))]
            : items
                .take(25)
                .map((item) => ListTile(
                      title: Text(
                          '${item['status'] ?? item['event_type'] ?? item['rule'] ?? item['entry_type'] ?? 'Record'}'),
                      subtitle: Text(
                          '${item['id'] ?? ''}\n${item['created_at'] ?? item['requested_at'] ?? ''}'),
                      isThreeLine: true,
                      trailing: _actionButton(item, actionType),
                    ))
                .toList(),
      ),
    );
  }

  Widget _actionButton(Map<String, dynamic> item, String? type) {
    final id = item['id']?.toString();
    if (id == null || id.isEmpty) return Text('${item['amount'] ?? item['refund_amount'] ?? ''}');
    if (type == null) return Text('${item['amount'] ?? item['refund_amount'] ?? ''}');
    
    if (type == 'fraud') {
      if (item['is_resolved'] == true) return const Text('Resolved');
      return IconButton(
        icon: const Icon(Icons.check_circle_outline),
        onPressed: () => _runAction(() => AdminRepository.resolveFraudFlag(id)),
        tooltip: 'Resolve',
      );
    }
    
    if (type == 'return') {
      if ('${item['status']}'.toLowerCase() == 'refunded') return const Text('Refunded');
      return IconButton(
        icon: const Icon(Icons.currency_exchange),
        onPressed: () => _runAction(() => AdminRepository.processRefund(id)),
        tooltip: 'Process refund',
      );
    }
    
    if (type == 'shipment') {
      return PopupMenuButton<String>(
        onSelected: (status) => _runAction(() => AdminRepository.updateShipmentStatus(id, status)),
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'packed', child: Text('Mark packed')),
          PopupMenuItem(value: 'ready_for_dispatch', child: Text('Ready for dispatch')),
          PopupMenuItem(value: 'in_transit', child: Text('In transit')),
          PopupMenuItem(value: 'delivered', child: Text('Delivered')),
          PopupMenuItem(value: 'returned', child: Text('Returned')),
          PopupMenuItem(value: 'failed_delivery', child: Text('Failed delivery')),
        ],
      );
    }
    
    if (type == 'settlement') {
      return PopupMenuButton<String>(
        onSelected: (status) => _runAction(() => AdminRepository.updateSettlementStatus(id, status)),
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'APPROVED', child: Text('Approve')),
          PopupMenuItem(value: 'PAID', child: Text('Mark paid')),
          PopupMenuItem(value: 'REJECTED', child: Text('Reject')),
          PopupMenuItem(value: 'FAILED', child: Text('Failed')),
        ],
      );
    }
    
    return Text('${item['amount'] ?? item['refund_amount'] ?? ''}');
  }
}