import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/review_repository.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';

class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen(
      {super.key, required this.productId, this.product});

  final String productId;
  final ProductModel? product;

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  late Future<List<Map<String, dynamic>>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = const ReviewRepository().getReviews(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final changed = await Navigator.pushNamed(
              context, addReviewsScreenRoute, arguments: {
            'productId': widget.productId,
            'product': widget.product
          });
          if (changed == true && mounted)
            setState(() => _reviewsFuture =
                const ReviewRepository().getReviews(widget.productId));
        },
        label: const Text('Write review'),
        icon: const Icon(Icons.rate_review_outlined),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text(snapshot.error.toString()));
          final reviews = snapshot.data ?? const <Map<String, dynamic>>[];
          if (reviews.isEmpty)
            return const Center(child: Text('No reviews yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(defaultPadding),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final review = reviews[index];
              final name =
                  '${review['first_name'] ?? ''} ${review['last_name'] ?? ''}'
                      .trim();
              return ListTile(
                title: Text(name.isEmpty ? 'Customer' : name),
                subtitle: Text(review['comment']?.toString() ?? ''),
                trailing: Text('${review['rating'] ?? 0}/5'),
              );
            },
          );
        },
      ),
    );
  }
}
