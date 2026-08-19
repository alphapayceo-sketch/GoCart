import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/data/product_repository.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.categoryId});

  final String? categoryId;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductRepository _repository = DemoProductRepository();
  late final TextEditingController _controller;
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _productsFuture = _repository.searchProducts(categoryId: widget.categoryId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    setState(() {
      _productsFuture = _repository.searchProducts(
          query: _controller.text, categoryId: widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search products, brands and more',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                    onPressed: _search, icon: const Icon(Icons.arrow_forward)),
                filled: true,
                fillColor: blackColor5,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: defaultPadding),
            Expanded(
              child: FutureBuilder<List<ProductModel>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Unable to load products.'));
                  }
                  final products = snapshot.data ?? const <ProductModel>[];
                  if (products.isEmpty) {
                    return const Center(child: Text('No products found.'));
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: defaultPadding,
                            mainAxisSpacing: defaultPadding,
                            childAspectRatio: .62),
                    itemCount: products.length,
                    itemBuilder: (context, index) => ProductCard(
                      image: products[index].image,
                      brandName: products[index].brandName,
                      title: products[index].title,
                      price: products[index].price,
                      priceAfetDiscount: products[index].priceAfetDiscount,
                      dicountpercent: products[index].dicountpercent,
                      press: () => Navigator.pushNamed(
                          context, productDetailsScreenRoute,
                          arguments: products[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
