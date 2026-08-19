import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/data/cart_repository.dart';
import 'package:shop/data/product_repository.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/views/added_to_cart_message_screen.dart';
import 'package:shop/screens/product/views/components/product_list_tile.dart';
import 'package:shop/screens/product/views/location_permission_store_availability_screen.dart';
import 'package:shop/screens/product/views/size_guide_screen.dart';

import '../../../constants.dart';
import 'components/product_quantity.dart';
import 'components/selected_colors.dart';
import 'components/selected_size.dart';
import 'components/unit_price.dart';

class ProductBuyNowScreen extends StatefulWidget {
  const ProductBuyNowScreen({
    super.key,
    required this.product,
  });

  final ProductModel? product;

  @override
  State<ProductBuyNowScreen> createState() => _ProductBuyNowScreenState();
}

class _ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  final ProductRepository _productRepository = DemoProductRepository();
  final CartRepository _cartRepository = RemoteCartRepository();
  int _quantity = 1;
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;
  late final Future<ProductModel> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _loadProduct();
  }

  Future<ProductModel> _loadProduct() async {
    final product = widget.product;
    if (product == null || product.id == null || product.id!.isEmpty) {
      throw Exception('Unable to load product details.');
    }

    if (product.variants.isNotEmpty) {
      _setInitialSelections(product);
      return product;
    }

    final fetchedProduct = await _productRepository.getProductById(product.id!);
    _setInitialSelections(fetchedProduct);
    return fetchedProduct;
  }

  void _setInitialSelections(ProductModel product) {
    final colors = _uniqueColorNames(product.variants);
    final sizes = _uniqueSizeNames(product.variants);

    _selectedColorIndex = colors.isNotEmpty ? 0 : _selectedColorIndex;
    _selectedSizeIndex = sizes.isNotEmpty ? 0 : _selectedSizeIndex;
  }

  List<String> _uniqueColorNames(List<ProductVariant> variants) {
    final seen = <String>{};
    final result = <String>[];

    for (final variant in variants) {
      final color = variant.color?.trim() ?? '';
      if (color.isEmpty) {
        continue;
      }
      final lower = color.toLowerCase();
      if (seen.add(lower)) {
        result.add(color);
      }
    }

    return result;
  }

  List<Color> _colorValues(List<String> colorNames) {
    return colorNames.map(_mapColorName).toList();
  }

  Color _mapColorName(String name) {
    final normalized = name.trim().toLowerCase();
    if (normalized.startsWith('#')) {
      try {
        final hex = normalized.replaceFirst('#', '');
        final parsed = int.parse(hex, radix: 16);
        return Color(hex.length == 6 ? 0xFF000000 | parsed : parsed);
      } catch (_) {
        return const Color(0xFF9E9E9E);
      }
    }

    switch (normalized) {
      case 'red':
        return const Color(0xFFEA6262);
      case 'green':
      case 'lime':
      case 'olive':
        return const Color(0xFFB1CC63);
      case 'yellow':
      case 'gold':
        return const Color(0xFFFFBF5F);
      case 'teal':
      case 'cyan':
      case 'aqua':
        return const Color(0xFF9FE1DD);
      case 'purple':
      case 'violet':
        return const Color(0xFFC482DB);
      case 'blue':
        return const Color(0xFF4A90E2);
      case 'black':
        return const Color(0xFF212121);
      case 'white':
        return const Color(0xFFFFFFFF);
      case 'pink':
        return const Color(0xFFFF8A80);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  List<String> _uniqueSizeNames(List<ProductVariant> variants) {
    final seen = <String>{};
    final result = <String>[];

    for (final variant in variants) {
      final size = variant.size?.trim().toUpperCase() ?? '';
      if (size.isEmpty) {
        continue;
      }
      if (seen.add(size)) {
        result.add(size);
      }
    }

    return result;
  }

  ProductVariant? _currentVariant(ProductModel product) {
    if (product.variants.isEmpty) {
      return null;
    }

    final colorNames = _uniqueColorNames(product.variants);
    final sizeNames = _uniqueSizeNames(product.variants);
    if (colorNames.isEmpty || sizeNames.isEmpty) {
      return null;
    }

    final selectedColor =
        colorNames[_selectedColorIndex.clamp(0, colorNames.length - 1)];
    final selectedSize =
        sizeNames[_selectedSizeIndex.clamp(0, sizeNames.length - 1)];

    return product.variants.firstWhere(
      (variant) =>
          variant.color?.toLowerCase() == selectedColor.toLowerCase() &&
          variant.size?.toUpperCase() == selectedSize.toUpperCase(),
      orElse: () => product.variants.first,
    );
  }

  void _onColorSelected(int index, ProductModel product) {
    final colorNames = _uniqueColorNames(product.variants);
    final sizeNames = _uniqueSizeNames(product.variants);
    if (index < 0 || index >= colorNames.length) {
      return;
    }

    setState(() {
      _selectedColorIndex = index;
      final selectedColor = colorNames[index].toLowerCase();
      final validSizes = product.variants
          .where((variant) => variant.color?.toLowerCase() == selectedColor)
          .map((variant) => variant.size?.toUpperCase() ?? '')
          .where((size) => size.isNotEmpty)
          .toSet()
          .toList();
      if (validSizes.isNotEmpty && _selectedSizeIndex >= sizeNames.length) {
        _selectedSizeIndex = sizeNames.indexOf(validSizes.first);
      }
    });
  }

  void _onSizeSelected(int index, ProductModel product) {
    final colorNames = _uniqueColorNames(product.variants);
    final sizeNames = _uniqueSizeNames(product.variants);
    if (index < 0 || index >= sizeNames.length) {
      return;
    }

    setState(() {
      _selectedSizeIndex = index;
      final selectedSize = sizeNames[index].toUpperCase();
      final validColors = product.variants
          .where((variant) => variant.size?.toUpperCase() == selectedSize)
          .map((variant) => variant.color?.trim() ?? '')
          .where((color) => color.isNotEmpty)
          .toSet()
          .toList();
      if (validColors.isNotEmpty && _selectedColorIndex >= colorNames.length) {
        _selectedColorIndex = 0;
      }
    });
  }

  Future<void> _handleAddToCart(
      BuildContext context, ProductModel product) async {
    if (product.id == null || product.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to add this product to cart.')),
      );
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final selectedVariant = _currentVariant(product);

    if (product.variants.isNotEmpty && selectedVariant == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please select a valid color and size.')),
      );
      return;
    }

    try {
      await _cartRepository.addToCart(
        productId: product.id!,
        quantity: _quantity,
        variantId: selectedVariant?.id,
      );
      if (!mounted) return;
      navigator.pop();
      customModalBottomSheet(
        navigator.context,
        isDismissible: false,
        child: const AddedToCartMessageScreen(),
      );
    } catch (error) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity += 1;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductModel>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Product Details'),
            ),
            body: Center(
              child:
                  Text(snapshot.error?.toString() ?? 'Unable to load product.'),
            ),
          );
        }

        final product = snapshot.data!;
        final price = product.price;
        final title = product.title;
        final image =
            product.image.isNotEmpty ? product.image : productDemoImg1;
        final colorNames = product.variants.isNotEmpty
            ? _uniqueColorNames(product.variants)
            : const ['Red', 'Green', 'Yellow', 'Teal', 'Purple'];
        final sizeNames = product.variants.isNotEmpty
            ? _uniqueSizeNames(product.variants)
            : const ['S', 'M', 'L', 'XL', 'XXL'];
        final colorValues = _colorValues(colorNames);

        return Scaffold(
          bottomNavigationBar: CartButton(
            price: price,
            title: 'Add to cart',
            subTitle: 'Total price',
            press: () => _handleAddToCart(context, product),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding / 2, vertical: defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BackButton(),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).textTheme.bodyLarge!.color!,
                            BlendMode.srcIn,
                          )),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: AspectRatio(
                          aspectRatio: 1.05,
                          child: NetworkImageWithLoader(image),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(defaultPadding),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: UnitPrice(
                                price: price,
                                priceAfterDiscount:
                                    product.priceAfetDiscount ?? price,
                              ),
                            ),
                            ProductQuantity(
                              numOfItem: _quantity,
                              onIncrement: _incrementQuantity,
                              onDecrement: _decrementQuantity,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: Divider()),
                    SliverToBoxAdapter(
                      child: SelectedColors(
                        colors: colorValues,
                        selectedColorIndex: _selectedColorIndex.clamp(
                            0, colorValues.length - 1),
                        press: (value) => _onColorSelected(value, product),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SelectedSize(
                        sizes: sizeNames,
                        selectedIndex:
                            _selectedSizeIndex.clamp(0, sizeNames.length - 1),
                        press: (value) => _onSizeSelected(value, product),
                      ),
                    ),
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(vertical: defaultPadding),
                      sliver: ProductListTile(
                        title: 'Size guide',
                        svgSrc: 'assets/icons/Sizeguid.svg',
                        isShowBottomBorder: true,
                        press: () {
                          customModalBottomSheet(
                            context,
                            height: MediaQuery.of(context).size.height * 0.9,
                            child: const SizeGuideScreen(),
                          );
                        },
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: defaultPadding / 2),
                            Text(
                              'Store pickup availability',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: defaultPadding / 2),
                            const Text(
                                'Select a size to check store availability and In-Store pickup options.'),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(vertical: defaultPadding),
                      sliver: ProductListTile(
                        title: 'Check stores',
                        svgSrc: 'assets/icons/Stores.svg',
                        isShowBottomBorder: true,
                        press: () {
                          customModalBottomSheet(
                            context,
                            height: MediaQuery.of(context).size.height * 0.92,
                            child:
                                const LocationPermissonStoreAvailabilityScreen(),
                          );
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(
                        child: SizedBox(height: defaultPadding))
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
