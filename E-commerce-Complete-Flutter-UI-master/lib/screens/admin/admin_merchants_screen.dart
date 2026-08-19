import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/admin_repository.dart';

class AdminMerchantsScreen extends StatefulWidget {
  const AdminMerchantsScreen({super.key});

  @override
  State<AdminMerchantsScreen> createState() => _AdminMerchantsScreenState();
}

class _AdminMerchantsScreenState extends State<AdminMerchantsScreen> {
  late Future<List<Map<String, dynamic>>> _merchants;

  @override
  void initState() {
    super.initState();
    _merchants = AdminRepository.getMerchants();
  }

  Future<void> _reload() async {
    setState(() => _merchants = AdminRepository.getMerchants());
    await _merchants;
  }

  Future<void> _setStatus(String merchantId, String status) async {
    try {
      await AdminRepository.updateMerchantStatus(merchantId, status);
      await _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Merchant status changed to $status')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage merchants'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _merchants,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: ElevatedButton(
                  onPressed: _reload,
                  child: Text('Failed to load merchants: ${snapshot.error}'),
                ),
              );
            }
            final merchants = snapshot.data ?? [];
            if (merchants.isEmpty) {
              return const Center(child: Text('No merchants found.'));
            }
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView.separated(
                itemCount: merchants.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final merchant = merchants[index];
                  final status = '${merchant['status'] ?? 'pending'}';
                  final merchantId = '${merchant['merchant_id'] ?? ''}';
                  final name =
                      '${merchant['business_name'] ?? 'Unnamed business'}';
                  final email = '${merchant['email'] ?? 'No email'}';
                  return ListTile(
                    title: Text(name),
                    subtitle: Text('$email\nStatus: $status'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => _setStatus(merchantId, value),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                            value: 'approved', child: Text('Approve')),
                        PopupMenuItem(value: 'active', child: Text('Activate')),
                        PopupMenuItem(value: 'rejected', child: Text('Reject')),
                        PopupMenuItem(
                            value: 'suspended', child: Text('Suspend')),
                        PopupMenuItem(
                            value: 'pending', child: Text('Set pending')),
                      ],
                    ),
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
