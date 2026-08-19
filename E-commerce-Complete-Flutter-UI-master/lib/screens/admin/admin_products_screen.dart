import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/admin_repository.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  late Future<List<ProductModel>> _productsFuture;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _page = 0;
  static const _pageSize = 20;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _productsFuture = AdminRepository.getAdminProducts();
  }

  Future<void> _reloadProducts() async {
    setState(() {
      _productsFuture = AdminRepository.getAdminProducts();
    });
    await _productsFuture;
  }

  Future<void> _deleteProduct(String id) async {
    await AdminRepository.deleteProduct(id);
    await _reloadProducts();
  }

  Future<void> _confirmDelete(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete product'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
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

  Widget _buildProductTile(ProductModel product) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
      child: ListTile(
        leading: SizedBox(
          width: 64,
          height: 64,
          child: product.image.isNotEmpty
              ? Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    size: 32,
                  ),
                )
              : const Icon(
                  Icons.image,
                  size: 32,
                ),
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
            Text(
              product.categoryName?.isNotEmpty == true
                  ? 'Category: ${product.categoryName}'
                  : 'Category: Unspecified',
              style: const TextStyle(fontSize: 12),
            ),
            if (product.stockQuantity != null)
              Text(
                'Stock: ${product.stockQuantity}',
                style: TextStyle(
                  fontSize: 12,
                  color: product.stockQuantity! > 0 ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatCurrency(product.price)),
                if (product.priceAfetDiscount != null)
                  Text(
                    formatCurrency(product.priceAfetDiscount!),
                    style: const TextStyle(color: Colors.green),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  adminEditProductScreenRoute,
                  arguments: product,
                ).then((_) => _reloadProducts());
              },
              tooltip: 'Edit product',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(product),
              tooltip: 'Delete product',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadProducts,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, adminCreateProductScreenRoute)
                  .then((_) => _reloadProducts());
            },
            tooltip: 'Create product',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, adminCreateProductScreenRoute)
              .then((_) => _reloadProducts());
        },
        tooltip: 'Create product',
        child: const Icon(Icons.add),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Failed to load products.'),
                    const SizedBox(height: defaultPadding),
                    Text(snapshot.error.toString()),
                    const SizedBox(height: defaultPadding),
                    ElevatedButton(
                      onPressed: _reloadProducts,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final products = snapshot.data ?? [];
            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No products found.'),
                    const SizedBox(height: defaultPadding),
                    ElevatedButton(
                      onPressed: _reloadProducts,
                      child: const Text('Reload'),
                    ),
                  ],
                ),
              );
            }

            final filtered = products.where((product) {
              final query = _searchQuery.trim().toLowerCase();
              return query.isEmpty ||
                  product.title.toLowerCase().contains(query) ||
                  product.brandName.toLowerCase().contains(query) ||
                  (product.categoryName ?? '').toLowerCase().contains(query);
            }).toList();
            final start = (_page * _pageSize).clamp(0, filtered.length);
            final end = (start + _pageSize).clamp(0, filtered.length);
            final visible = filtered.sublist(start, end);
            if (visible.isEmpty)
              return const Center(child: Text('No matching products found.'));
            return Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                      labelText: 'Search products',
                      prefixIcon: Icon(Icons.search)),
                  onChanged: (value) => setState(() {
                    _searchQuery = value;
                    _page = 0;
                  }),
                ),
                const SizedBox(height: defaultPadding),
                Expanded(
                    child: RefreshIndicator(
                  onRefresh: _reloadProducts,
                  child: ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) =>
                        _buildProductTile(visible[index]),
                  ),
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed:
                            _page > 0 ? () => setState(() => _page--) : null,
                        icon: const Icon(Icons.chevron_left)),
                    Text(
                        'Page ${_page + 1} of ${(filtered.length / _pageSize).ceil()}'),
                    IconButton(
                        onPressed: end < filtered.length
                            ? () => setState(() => _page++)
                            : null,
                        icon: const Icon(Icons.chevron_right)),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
