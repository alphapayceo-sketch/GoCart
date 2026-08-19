import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/components/review_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/screens/product/views/components/notify_me_card.dart';
import 'package:shop/screens/product/views/components/product_images.dart';
import 'package:shop/screens/product/views/components/product_info.dart';
import 'package:shop/screens/product/views/components/product_list_tile.dart';
import 'package:shop/screens/product/views/product_buy_now_screen.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    this.product,
    this.isProductAvailable = true,
  });

  final ProductModel? product;
  final bool isProductAvailable;

  String get _brand => (product?.brandName.isNotEmpty ?? false)
      ? product!.brandName
      : 'LIPSY LONDON';

  String get _title => (product?.title.isNotEmpty ?? false)
      ? product!.title
      : 'Sleeveless Ruffle';

  String get _description => (product?.description != null &&
          product!.description!.trim().isNotEmpty)
      ? product!.description!
      : 'Premium product from ${_brand.toUpperCase()} featuring ${_title.toLowerCase()}. Crafted for comfort, style, and daily wear.';

  double get _price => product?.price ?? 140;

  double get _discountPrice => product?.priceAfetDiscount ?? _price;

  List<String> get _secondaryImages {
    final primary =
        product?.imageUrls.isNotEmpty == true ? product!.imageUrls : <String>[];
    final fallback = [productDemoImg1, productDemoImg2, productDemoImg3];
    final images = <String>[];
    images.addAll(primary);
    for (final item in fallback) {
      if (item.isNotEmpty && !images.contains(item)) {
        images.add(item);
      }
    }
    return images.isNotEmpty ? images : fallback;
  }

  @override
  Widget build(BuildContext context) {
    final image =
        product?.image.isNotEmpty == true ? product!.image : productDemoImg1;
    final title = _title;
    final brand = _brand;
    final price = _price;
    final discountPrice = _discountPrice;
    final secondaryImages = _secondaryImages;

    return Scaffold(
      bottomNavigationBar: isProductAvailable
          ? CartButton(
              price: price,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: ProductBuyNowScreen(product: product),
                );
              },
            )
          :

          /// If profuct is not available then show [NotifyMeCard]
          NotifyMeCard(
              isNotify: false,
              onChanged: (value) {},
            ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    "assets/icons/Bookmark.svg",
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).textTheme.bodyLarge!.color ??
                          Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            ProductImages(
              images: secondaryImages,
            ),
            ProductInfo(
              brand: brand.toUpperCase(),
              title: title,
              isAvailable: isProductAvailable,
              description: _description,
              rating: 4.4,
              numOfReviews: 126,
            ),
            ProductListTile(
              svgSrc: "assets/icons/Product.svg",
              title: "Product Details",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Product Details",
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: defaultPadding),
                        const Text(
                            "This high-quality product is designed for comfort and style. Made from premium materials, it ensures durability and a great fit for all occasions.",
                            style: TextStyle(color: blackColor40)),
                      ],
                    ),
                  ),
                );
              },
            ),
            ProductListTile(
              svgSrc: "assets/icons/Delivery.svg",
              title: "Shipping Information",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Shipping Information",
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: defaultPadding),
                        const Text(
                            "We offer fast and reliable shipping. Standard delivery takes 5-7 business days, while express options are available at checkout.",
                            style: TextStyle(color: blackColor40)),
                      ],
                    ),
                  ),
                );
              },
            ),
            ProductListTile(
              svgSrc: "assets/icons/Return.svg",
              title: "Returns",
              isShowBottomBorder: true,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductReturnsScreen(),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: ReviewCard(
                  rating: 4.3,
                  numOfReviews: 128,
                  numOfFiveStar: 80,
                  numOfFourStar: 30,
                  numOfThreeStar: 5,
                  numOfTwoStar: 4,
                  numOfOneStar: 1,
                ),
              ),
            ),
            ProductListTile(
              svgSrc: "assets/icons/Chat.svg",
              title: "Reviews",
              isShowBottomBorder: true,
              press: () {
                Navigator.pushNamed(context, productReviewsScreenRoute,
                    arguments: product);
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "You may also like",
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(
                        left: defaultPadding,
                        right: index == 4 ? defaultPadding : 0),
                    child: ProductCard(
                      image: image,
                      title: title,
                      brandName: brand,
                      price: price,
                      priceAfetDiscount: discountPrice,
                      dicountpercent: product?.dicountpercent,
                      press: () {},
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            )
          ],
        ),
      ),
    );
  }
}
