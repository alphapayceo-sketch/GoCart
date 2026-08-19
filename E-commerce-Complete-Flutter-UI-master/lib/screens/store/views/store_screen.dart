import 'package:flutter/material.dart';
import 'package:shop/components/app_bottom_navigation.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/cart_repository.dart';
import 'package:shop/data/product_repository.dart';
import 'package:shop/data/wishlist_repository.dart';
import 'package:shop/data/user_repository.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key, required this.storeName});

  final String storeName;

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final ProductRepository _products = DemoProductRepository();
  final WishlistRepository _wishlist = RemoteWishlistRepository();
  final CartRepository _cart = RemoteCartRepository();
  late final TextEditingController _searchController;
  late Future<List<ProductModel>> _productsFuture;
  Set<String> _savedIds = <String>{};
  String _query = '';
  String _category = 'All';
  bool _following = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _productsFuture = _products.getStoreProducts(widget.storeName);
    _loadSavedProducts();
    _loadFollowState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedProducts() async {
    try {
      final saved = await _wishlist.getWishlist();
      if (mounted) {
        setState(() => _savedIds =
            saved.map((item) => item.id).whereType<String>().toSet());
      }
    } catch (_) {
      // The screen still remains usable when the visitor is signed out.
    }
  }

  Future<void> _loadFollowState() async {
    try {
      final stores = await UserRepository.getFollowedStores();
      final followed = stores
          .whereType<Map>()
          .any((item) => item['brand_name']?.toString() == widget.storeName);
      if (mounted) setState(() => _following = followed);
    } catch (_) {
      // Follow controls remain available when the visitor is signed out.
    }
  }

  Future<void> _toggleFollow() async {
    final previous = _following;
    setState(() => _following = !previous);
    try {
      if (previous) {
        await UserRepository.unfollowStore(widget.storeName);
      } else {
        await UserRepository.followStore(widget.storeName);
      }
    } catch (_) {
      if (mounted) setState(() => _following = previous);
    }
  }

  Future<void> _toggleSaved(ProductModel product) async {
    final id = product.id;
    if (id == null || id.isEmpty) return;
    final wasSaved = _savedIds.contains(id);
    setState(() => wasSaved ? _savedIds.remove(id) : _savedIds.add(id));
    try {
      if (wasSaved) {
        await _wishlist.removeFromWishlist(id);
      } else {
        await _wishlist.addToWishlist(id);
      }
    } catch (_) {
      if (mounted)
        setState(() => wasSaved ? _savedIds.add(id) : _savedIds.remove(id));
    }
  }

  Future<void> _addToCart(ProductModel product) async {
    final id = product.id;
    if (id == null || id.isEmpty) return;
    try {
      await _cart.addToCart(productId: id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.title} added to your bag')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not add this product to your bag')),
        );
      }
    }
  }

  void _openProduct(ProductModel product) {
    Navigator.pushNamed(context, productDetailsScreenRoute, arguments: product);
  }

  void _selectMainTab(int index) {
    if (index == 0) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      entryPointScreenRoute,
      (route) => false,
      arguments: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: darkGreyColor,
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _StoreMessage(
              message: 'Unable to load this store.',
              onRetry: () => setState(() => _productsFuture =
                  _products.getStoreProducts(widget.storeName)),
            );
          }
          final products = snapshot.data ?? const <ProductModel>[];
          final categories = <String>{
            'All',
            ...products.map((item) => item.categoryName).whereType<String>()
          }.where((item) => item.isNotEmpty).toList();
          final visible = products.where((product) {
            final categoryMatch =
                _category == 'All' || product.categoryName == _category;
            final searchMatch = _query.trim().isEmpty ||
                '${product.title} ${product.brandName} ${product.categoryName ?? ''}'
                    .toLowerCase()
                    .contains(_query.trim().toLowerCase());
            return categoryMatch && searchMatch;
          }).toList();
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: _StoreHero(
                storeName: widget.storeName,
                product: products.isEmpty ? null : products.first,
                following: _following,
                onBack: () => Navigator.pop(context),
                onFollow: _toggleFollow,
              )),
              SliverToBoxAdapter(
                  child: _CategoryBar(
                      categories: categories,
                      selected: _category,
                      onSelected: (value) =>
                          setState(() => _category = value))),
              SliverToBoxAdapter(
                  child: _StoreSearch(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value))),
              SliverToBoxAdapter(
                  child: _StoreHeading(
                      title: _category == 'All' ? 'All products' : _category,
                      count: visible.length)),
              if (visible.isEmpty)
                const SliverToBoxAdapter(
                    child: _StoreMessage(message: 'No matching products.'))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => _StoreProductCard(
                        product: visible[index],
                        saved: _savedIds.contains(visible[index].id),
                        onTap: () => _openProduct(visible[index]),
                        onSave: () => _toggleSaved(visible[index]),
                        onAdd: () => _addToCart(visible[index]),
                      ),
                      childCount: visible.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width >= 1000
                          ? 4
                          : width >= 700
                              ? 3
                              : 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 18,
                      childAspectRatio: width >= 700 ? .7 : .63,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        onTap: _selectMainTab,
      ),
    );
  }
}

class _StoreHero extends StatelessWidget {
  const _StoreHero(
      {required this.storeName,
      required this.product,
      required this.following,
      required this.onBack,
      required this.onFollow});

  final String storeName;
  final ProductModel? product;
  final bool following;
  final VoidCallback onBack;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    final image = product?.image ?? '';
    return SizedBox(
      height: 330,
      child: Stack(fit: StackFit.expand, children: [
        if (image.isNotEmpty)
          Image.network(image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: darkGreyColor))
        else
          Container(color: darkGreyColor),
        Container(color: Colors.black.withValues(alpha: .46)),
        SafeArea(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              IconButton(
                  onPressed: onBack,
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_back_rounded)),
              const Spacer(),
              FilledButton(
                  onPressed: onFollow,
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: .22),
                      foregroundColor: Colors.white),
                  child: Text(following ? 'Following' : 'Follow')),
            ]),
            const Spacer(),
            Text(storeName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w300)),
            const SizedBox(height: 6),
            const Text('Independent shop',
                style: TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 10),
            const Text('4.8 ★  Store collection',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ]),
        )),
      ]),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar(
      {required this.categories,
      required this.selected,
      required this.onSelected});

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 58,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, index) => ChoiceChip(
            label: Text(
                categories[index] == 'All' ? 'Shop all' : categories[index]),
            selected: selected == categories[index],
            onSelected: (_) => onSelected(categories[index]),
          ),
        ),
      );
}

class _StoreSearch extends StatelessWidget {
  const _StoreSearch({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search this shop',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
          ),
        ),
      );
}

class _StoreHeading extends StatelessWidget {
  const _StoreHeading({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
        child: Row(children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w700))),
          Text('$count items', style: const TextStyle(color: Colors.white70)),
        ]),
      );
}

class _StoreProductCard extends StatelessWidget {
  const _StoreProductCard(
      {required this.product,
      required this.saved,
      required this.onTap,
      required this.onSave,
      required this.onAdd});

  final ProductModel product;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Stack(children: [
              Positioned.fill(
                  child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: product.image.isEmpty
                    ? Container(color: lightGreyColor)
                    : Image.network(product.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: lightGreyColor)),
              )),
              Positioned(
                  top: 7,
                  right: 7,
                  child: IconButton(
                    onPressed: onSave,
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: .88)),
                    icon: Icon(
                        saved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: saved ? errorColor : blackColor,
                        size: 20),
                  )),
              Positioned(
                  bottom: 7,
                  right: 7,
                  child: IconButton(
                    onPressed: onAdd,
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: .88)),
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                  )),
            ])),
            const SizedBox(height: 7),
            Text(product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            const SizedBox(height: 4),
            Text(formatCurrency(product.price),
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ]),
        ),
      );
}

class _StoreMessage extends StatelessWidget {
  const _StoreMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message, style: const TextStyle(color: Colors.white70)),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry')),
          ],
        ])),
      );
}
