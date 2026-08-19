import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';

import 'package:shop/route/screen_export.dart';

import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import '../../../components/review_card.dart';
import 'product_buy_now_screen.dart';

export 'components/product_info.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    this.product,
    this.isProductAvailable = true,
  });

  final ProductModel? product;
  final bool isProductAvailable;

  String get _brandName => (product?.brandName.isNotEmpty ?? false)
      ? product!.brandName
      : 'LIPSY LONDON';

  String get _title => (product?.title.isNotEmpty ?? false)
      ? product!.title
      : 'Sleeveless Ruffle';

  String get _description => (product?.description != null &&
          product!.description!.trim().isNotEmpty)
      ? product!.description!
      : 'Premium product designed for everyday comfort, style, and dependable quality.';

  List<String> get _images {
    if (product != null && product!.imageUrls.isNotEmpty) {
      return product!.imageUrls;
    }
    return const [productDemoImg1, productDemoImg2, productDemoImg3];
  }

  double get _displayPrice {
    final productPrice = product?.price ?? 0;
    final discountedPrice = product?.priceAfetDiscount ?? productPrice;
    return discountedPrice > 0 ? discountedPrice : productPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: isProductAvailable
          ? CartButton(
              price: _displayPrice,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: ProductBuyNowScreen(product: product),
                );
              },
            )
          : NotifyMeCard(
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
                    'assets/icons/Bookmark.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).textTheme.bodyLarge!.color ??
                          Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            ProductImages(images: _images),
            ProductInfo(
              brand: _brandName,
              title: _title,
              isAvailable: isProductAvailable,
              description: _description,
              rating: 4.4,
              numOfReviews: 126,
            ),
            ProductListTile(
              svgSrc: 'assets/icons/Product.svg',
              title: 'Product Details',
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Details',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: defaultPadding),
                        const Text(
                          'This high-quality product is designed for comfort and style. The fabric is premium, durable, and built for daily wear.',
                          style: TextStyle(color: blackColor40),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            ProductListTile(
              svgSrc: 'assets/icons/Delivery.svg',
              title: 'Shipping Information',
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shipping Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: defaultPadding),
                        const Text(
                          'We offer reliable shipping with standard delivery in 5–7 business days and express delivery available at checkout.',
                          style: TextStyle(color: blackColor40),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            ProductListTile(
              svgSrc: 'assets/icons/Return.svg',
              title: 'Returns',
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
              svgSrc: 'assets/icons/Chat.svg',
              title: 'Reviews',
              isShowBottomBorder: true,
              press: () {
                Navigator.pushNamed(context, productReviewsScreenRoute);
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'You may also like',
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
                      image: productDemoImg2,
                      title: 'Sleeveless Tiered Dobby Swing Dress',
                      brandName: 'LIPSY LONDON',
                      price: 24.65,
                      priceAfetDiscount: index.isEven ? 20.99 : null,
                      dicountpercent: index.isEven ? 25 : null,
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
