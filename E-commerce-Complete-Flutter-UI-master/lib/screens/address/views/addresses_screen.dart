import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/user_repository.dart';
import 'package:shop/route/route_constants.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  late Future<List<dynamic>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _addressesFuture = UserRepository.getAddresses();
  }

  Future<void> _addAddress() async {
    final changed =
        await Navigator.pushNamed(context, addNewAddressesScreenRoute);
    if (changed == true && mounted) {
      setState(() => _addressesFuture = UserRepository.getAddresses());
    }
  }

  Future<void> _deleteAddress(String id) async {
    try {
      await UserRepository.deleteAddress(id);
      if (mounted)
        setState(() => _addressesFuture = UserRepository.getAddresses());
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      floatingActionButton: FloatingActionButton(
          onPressed: _addAddress, child: const Icon(Icons.add)),
      body: FutureBuilder<List<dynamic>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text(snapshot.error.toString()));
          final addresses = snapshot.data ?? const <dynamic>[];
          if (addresses.isEmpty)
            return const Center(child: Text('No saved addresses.'));
          return ListView.builder(
            padding: const EdgeInsets.all(defaultPadding),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address =
                  Map<String, dynamic>.from(addresses[index] as Map);
              return Card(
                child: ListTile(
                  title: Text(address['is_default'] == true
                      ? 'Default address'
                      : 'Saved address'),
                  subtitle: Text(_addressBody(address)),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          _deleteAddress(address['id'].toString())),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _addressBody(Map<String, dynamic> address) => [
        address['address_line1'],
        address['address_line2'],
        address['city'],
        address['state'],
        address['postal_code'],
        address['country']
      ].whereType<String>().where((part) => part.isNotEmpty).join(', ');
}
