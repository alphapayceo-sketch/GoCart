import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/wishlist_repository.dart';
import 'package:shop/models/product_model.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  static final WishlistRepository _repository = RemoteWishlistRepository();
  late final Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _repository.getWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wishlist"),
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Unable to load wishlist.'));
          }

          final products = snapshot.data!;
          if (products.isEmpty) {
            return const Center(child: Text('Your wishlist is empty.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(defaultPadding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: defaultPadding,
              crossAxisSpacing: defaultPadding,
              childAspectRatio: 0.7,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildWishlistItem(context, products[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildWishlistItem(BuildContext context, ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: blackColor5,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(defaultBorderRadious)),
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.image_outlined)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite, color: errorColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(formatCurrency(product.priceAfetDiscount ?? product.price),
                    style: const TextStyle(color: primaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
