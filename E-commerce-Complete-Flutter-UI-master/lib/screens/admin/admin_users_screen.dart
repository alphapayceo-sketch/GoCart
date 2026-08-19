import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/admin_repository.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late Future<List<Map<String, dynamic>>> _users;

  @override
  void initState() {
    super.initState();
    _users = AdminRepository.getUsers();
  }

  Future<void> _reload() async {
    setState(() => _users = AdminRepository.getUsers());
    await _users;
  }

  Future<void> _changeRole(String id, String role) async {
    try {
      await AdminRepository.updateUserRole(id, role);
      await _reload();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _changeStatus(String id, bool deleted) async {
    try {
      await AdminRepository.updateUserStatus(id, deleted);
      await _reload();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage users'), actions: [
        IconButton(onPressed: _reload, icon: const Icon(Icons.refresh))
      ]),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _users,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return Center(
                  child: ElevatedButton(
                      onPressed: _reload,
                      child: Text('Failed to load users: ${snapshot.error}')));
            final users = snapshot.data ?? [];
            if (users.isEmpty)
              return const Center(child: Text('No users found.'));
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView.separated(
                itemCount: users.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final id = '${user['id'] ?? ''}';
                  final role = '${user['role'] ?? 'customer'}';
                  final deleted = user['deleted_at'] != null;
                  final displayName =
                      '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'
                          .trim();
                  return ListTile(
                    title: Text(displayName.isEmpty
                        ? '${user['email'] ?? 'User'}'
                        : displayName),
                    subtitle: Text(
                        '${user['email'] ?? 'No email'}\nRole: $role${deleted ? '\nDisabled' : ''}'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'customer' || value == 'merchant')
                          _changeRole(id, value);
                        if (value == 'disable') _changeStatus(id, true);
                        if (value == 'enable') _changeStatus(id, false);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'customer', child: Text('Make customer')),
                        const PopupMenuItem(
                            value: 'merchant', child: Text('Make merchant')),
                        PopupMenuItem(
                            value: deleted ? 'enable' : 'disable',
                            child: Text(deleted
                                ? 'Enable account'
                                : 'Disable account')),
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
