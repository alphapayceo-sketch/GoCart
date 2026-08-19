import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/cart_repository.dart';
import 'package:shop/data/category_repository.dart';
import 'package:shop/data/product_repository.dart';
import 'package:shop/data/wishlist_repository.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductRepository _repository = DemoProductRepository();
  final CategoryRepository _categoryRepository = DemoCategoryRepository();
  final WishlistRepository _wishlistRepository = RemoteWishlistRepository();
  final CartRepository _cartRepository = RemoteCartRepository();
  late Future<List<ProductModel>> _productsFuture;
  late Future<List<CategoryModel>> _categoriesFuture;
  final Set<String> _wishlistIds = <String>{};
  List<String> _recentIds = <String>[];

  static const _recentProductsKey = 'recent_product_ids';

  @override
  void initState() {
    super.initState();
    _productsFuture = _repository.getPopularProducts();
    _categoriesFuture = _categoryRepository.getCategoryCards();
    _loadUserState();
  }

  void _openProduct(ProductModel product) {
    _rememberProduct(product);
    Navigator.pushNamed(context, productDetailsScreenRoute, arguments: product);
  }

  void _openSearch() => Navigator.pushNamed(context, searchScreenRoute);

  void _openCart() => Navigator.pushNamed(context, cartScreenRoute);

  void _openWishlist() => Navigator.pushNamed(context, wishlistScreenRoute);

  void _openStore(String storeName) {
    Navigator.pushNamed(context, brandScreenRoute, arguments: storeName);
  }

  Future<void> _loadUserState() async {
    final prefs = await SharedPreferences.getInstance();
    final recentIds = prefs.getStringList(_recentProductsKey) ?? <String>[];
    try {
      final wishlist = await _wishlistRepository.getWishlist();
      if (!mounted) return;
      setState(() {
        _recentIds = recentIds;
        _wishlistIds
            .addAll(wishlist.map((product) => product.id).whereType<String>());
      });
    } catch (_) {
      if (mounted) setState(() => _recentIds = recentIds);
    }
  }

  Future<void> _rememberProduct(ProductModel product) async {
    final id = product.id;
    if (id == null || id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _recentIds =
        [id, ..._recentIds.where((item) => item != id)].take(12).toList();
    await prefs.setStringList(_recentProductsKey, _recentIds);
  }

  Future<void> _toggleWishlist(ProductModel product) async {
    final id = product.id;
    if (id == null || id.isEmpty) return;
    final saved = _wishlistIds.contains(id);
    setState(() => saved ? _wishlistIds.remove(id) : _wishlistIds.add(id));
    try {
      if (saved) {
        await _wishlistRepository.removeFromWishlist(id);
      } else {
        await _wishlistRepository.addToWishlist(id);
      }
    } catch (_) {
      if (mounted) {
        setState(() => saved ? _wishlistIds.add(id) : _wishlistIds.remove(id));
      }
    }
  }

  Future<void> _addToCart(ProductModel product) async {
    final id = product.id;
    if (id == null || id.isEmpty) return;
    try {
      await _cartRepository.addToCart(productId: id);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Added to cart')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not add this product to cart')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final inset = width >= 1200
        ? (width - 1040) / 2
        : width >= 700
            ? 40.0
            : 20.0;

    return FutureBuilder<List<ProductModel>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data?.isEmpty != false) {
          return _HomeError(
            message: snapshot.hasError
                ? 'We could not load products.'
                : 'No products are available for this store yet.',
            onRetry: () => setState(
                () => _productsFuture = _repository.getPopularProducts()),
          );
        }

        final products = snapshot.data!;
        final firstGroup = products.take(3).toList();
        final secondGroup = products.skip(3).take(3).toList();
        final secondStoreProducts =
            secondGroup.isEmpty ? firstGroup : secondGroup;

        return CustomScrollView(slivers: [
          SliverToBoxAdapter(
              child: FutureBuilder<List<CategoryModel>>(
            future: _categoriesFuture,
            builder: (context, categorySnapshot) {
              final categories =
                  categorySnapshot.data ?? const <CategoryModel>[];
              if (categories.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 54,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: inset),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) => ActionChip(
                    label: Text(categories[index].title),
                    onPressed: () => Navigator.pushNamed(
                        context, searchScreenRoute,
                        arguments: categories[index].id),
                  ),
                ),
              );
            },
          )),
          SliverToBoxAdapter(
              child: Padding(
            padding: EdgeInsets.fromLTRB(inset, 12, inset, 0),
            child: _QuickActions(
                onSearch: _openSearch,
                onCart: _openCart,
                onWishlist: _openWishlist),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: inset),
            child: _JumpBackInCard(
                products: _recentProducts(products),
                onProductTap: _openProduct),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: inset),
            child: _EditorialStoreCard(
                store: _storeName(firstGroup.first),
                products: firstGroup,
                onProductTap: _openProduct,
                onStoreTap: _openStore,
                wishlistIds: _wishlistIds,
                onWishlist: _toggleWishlist,
                onAddToCart: _addToCart),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: inset),
            child: _EditorialStoreCard(
                store: _storeName(secondStoreProducts.first),
                products: secondStoreProducts,
                onProductTap: _openProduct,
                onStoreTap: _openStore,
                wishlistIds: _wishlistIds,
                onWishlist: _toggleWishlist,
                onAddToCart: _addToCart),
          )),
          SliverToBoxAdapter(
              child: Padding(
            padding: EdgeInsets.fromLTRB(inset, 24, inset, 34),
            child: const _ShopCashCard(),
          )),
        ]);
      },
    );
  }

  String _storeName(ProductModel product) {
    if (product.brandName.isNotEmpty) return product.brandName;
    if (product.categoryName?.isNotEmpty == true) return product.categoryName!;
    return 'Featured store';
  }

  List<ProductModel> _recentProducts(List<ProductModel> products) {
    final recent = <ProductModel>[];
    for (final id in _recentIds) {
      for (final product in products) {
        if (product.id == id) recent.add(product);
      }
    }
    return recent.isEmpty ? products.take(3).toList() : recent;
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
          child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: defaultPadding),
          FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry')),
        ]),
      ));
}

class _QuickActions extends StatelessWidget {
  const _QuickActions(
      {required this.onSearch, required this.onCart, required this.onWishlist});

  final VoidCallback onSearch;
  final VoidCallback onCart;
  final VoidCallback onWishlist;

  @override
  Widget build(BuildContext context) => SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          const _ActionChip(label: 'L', selected: true),
          const SizedBox(width: 8),
          _IconActionChip(icon: Icons.search_rounded, onTap: onSearch),
          const SizedBox(width: 8),
          _IconActionChip(icon: Icons.shopping_bag_outlined, onTap: onCart),
          const SizedBox(width: 8),
          const _ActionChip(icon: Icons.verified_rounded, label: 'Following'),
          const SizedBox(width: 8),
          _ActionChip(
              icon: Icons.favorite_rounded, label: 'Saved', onTap: onWishlist),
          const SizedBox(width: 8),
          _ActionChip(
              icon: Icons.group_rounded, label: 'Minis', onTap: onSearch),
        ],
      ));
}

class _ActionChip extends StatelessWidget {
  const _ActionChip(
      {required this.label, this.icon, this.selected = false, this.onTap});

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected
            ? const Color(0xFFD8D8D8)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              height: 54,
              padding: EdgeInsets.symmetric(horizontal: selected ? 19 : 17),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: blackColor20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 7)
                ],
                Text(label,
                    style: TextStyle(
                        fontSize: selected ? 22 : 16,
                        fontWeight: FontWeight.w800)),
              ]),
            )),
      );
}

class _IconActionChip extends StatelessWidget {
  const _IconActionChip({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        shape: const CircleBorder(),
        child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: blackColor20)),
              child: Icon(icon, size: 24),
            )),
      );
}

class _JumpBackInCard extends StatelessWidget {
  const _JumpBackInCard({required this.products, required this.onProductTap});

  final List<ProductModel> products;
  final ValueChanged<ProductModel> onProductTap;

  @override
  Widget build(BuildContext context) => Container(
        height: 330,
        padding: const EdgeInsets.fromLTRB(28, 28, 0, 0),
        decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(30)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Jump back in',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 28),
          Expanded(
              child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, index) => GestureDetector(
                onTap: () => onProductTap(products[index]),
                child: _ImagePanel(product: products[index])),
          )),
          const SizedBox(height: 18),
          const Padding(
              padding: EdgeInsets.only(right: 22, bottom: 22),
              child: Row(children: [
                Expanded(
                    child: Text('Recently viewed',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700))),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 24),
              ])),
        ]),
      );
}

class _EditorialStoreCard extends StatelessWidget {
  const _EditorialStoreCard(
      {required this.store,
      required this.products,
      required this.onProductTap,
      required this.onStoreTap,
      required this.wishlistIds,
      required this.onWishlist,
      required this.onAddToCart});

  final String store;
  final List<ProductModel> products;
  final ValueChanged<ProductModel> onProductTap;
  final ValueChanged<String> onStoreTap;
  final Set<String> wishlistIds;
  final ValueChanged<ProductModel> onWishlist;
  final ValueChanged<ProductModel> onAddToCart;

  @override
  Widget build(BuildContext context) {
    final background = products.first.image;
    return Container(
      height: 510,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: darkGreyColor,
        image: background.isEmpty
            ? null
            : DecorationImage(
                image: NetworkImage(background),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: .35), BlendMode.darken)),
      ),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 0, 22),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: () => onStoreTap(store),
              child: Row(children: [
                _Avatar(product: products.first),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(store,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800))),
                const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.more_horiz_rounded,
                        color: Colors.white, size: 27)),
              ]),
            ),
            const Spacer(),
            SizedBox(
                height: 225,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (_, index) => _EditorialProductCard(
                      product: products[index],
                      onTap: () => onProductTap(products[index]),
                      isSaved: wishlistIds.contains(products[index].id),
                      onWishlist: () => onWishlist(products[index]),
                      onAddToCart: () => onAddToCart(products[index])),
                )),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () => onStoreTap(store),
              child: const Padding(
                  padding: EdgeInsets.only(right: 22),
                  child: Row(children: [
                    Expanded(
                        child: Text('Shop all',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700))),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 24),
                  ])),
            ),
          ])),
    );
  }
}

class _EditorialProductCard extends StatelessWidget {
  const _EditorialProductCard({
    required this.product,
    required this.onTap,
    required this.isSaved,
    required this.onWishlist,
    required this.onAddToCart,
  });

  final ProductModel product;
  final VoidCallback onTap;
  final bool isSaved;
  final VoidCallback onWishlist;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(25)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Stack(children: [
            Positioned.fill(child: _ProductImage(product: product, radius: 19)),
            Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .94),
                      borderRadius: BorderRadius.circular(16)),
                  child: Text(formatCurrency(product.price),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w900)),
                )),
            Positioned(
                right: 9,
                bottom: 9,
                child: Row(children: [
                  InkWell(
                    onTap: onWishlist,
                    customBorder: const CircleBorder(),
                    child: CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: Icon(
                            isSaved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isSaved ? errorColor : blackColor,
                            size: 23)),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onAddToCart,
                    customBorder: const CircleBorder(),
                    child: const CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: Icon(Icons.add_shopping_cart_rounded, size: 20)),
                  ),
                ])),
          ])),
          const SizedBox(height: 7),
          Text(product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        ]),
      ));
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product, required this.radius});

  final ProductModel product;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: product.image.isEmpty
            ? Container(
                color: lightGreyColor,
                child: const Icon(Icons.image_outlined, size: 42))
            : Image.network(product.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    color: lightGreyColor,
                    child: const Icon(Icons.image_outlined, size: 42))),
      );
}

class _ImagePanel extends StatelessWidget {
  const _ImagePanel({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) => Container(
        width: 250,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: _ProductImage(product: product, radius: 28),
      );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white,
        backgroundImage:
            product.image.isEmpty ? null : NetworkImage(product.image),
        child: product.image.isEmpty
            ? const Icon(Icons.storefront_outlined)
            : null,
      );
}

class _ShopCashCard extends StatelessWidget {
  const _ShopCashCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFFE5DFFF),
            borderRadius: BorderRadius.circular(24)),
        child: const Row(children: [
          CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(Icons.auto_awesome, color: successColor)),
          SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('You have 240 Shop Cash',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Use it on your next eligible purchase.',
                    style: TextStyle(color: blackColor60)),
              ])),
          Icon(Icons.chevron_right_rounded),
        ]),
      );
}
