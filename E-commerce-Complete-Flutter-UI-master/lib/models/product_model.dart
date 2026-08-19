import 'package:flutter/foundation.dart';
import 'package:shop/constants.dart';

@immutable
class ProductVariant {
  const ProductVariant({
    required this.id,
    this.color,
    this.size,
    this.sku,
    this.additionalPrice,
    this.stockQuantity,
  });

  final String id;
  final String? color;
  final String? size;
  final String? sku;
  final double? additionalPrice;
  final int? stockQuantity;

  factory ProductVariant.fromBackendJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id']?.toString() ?? '',
      color: json['color']?.toString(),
      size: json['size']?.toString(),
      sku: json['sku']?.toString(),
      additionalPrice: (json['additional_price'] is num
          ? (json['additional_price'] as num).toDouble()
          : json['additional_price'] is String
              ? double.tryParse(json['additional_price'] as String)
              : null),
      stockQuantity: json['stock_quantity'] is int
          ? json['stock_quantity'] as int
          : json['stock_quantity'] is String
              ? int.tryParse(json['stock_quantity'] as String)
              : null,
    );
  }
}

@immutable
class ProductModel {
  final String? id;
  final String? cartItemId;
  final int? cartQuantity;
  final String title;
  final String brandName;
  final String? description;
  final double price;
  final double? priceAfetDiscount;
  final int? dicountpercent;
  final String? categoryId;
  final String? categoryName;
  final int? stockQuantity;
  final List<String> imageUrls;
  final List<ProductVariant> variants;

  const ProductModel({
    this.id,
    required this.title,
    required this.brandName,
    this.description,
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
    this.categoryId,
    this.categoryName,
    this.stockQuantity,
    this.cartItemId,
    this.cartQuantity,
    this.imageUrls = const [],
    this.variants = const [],
  });

  String get image => imageUrls.isNotEmpty ? imageUrls.first : '';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imageUrls = json['imageUrls'];
    final images = imageUrls is List
        ? imageUrls.map((item) => item.toString()).toList()
        : <String>[];

    final variantsJson = json['variants'];
    final variants = variantsJson is List
        ? variantsJson
            .whereType<Map<String, dynamic>>()
            .map(ProductVariant.fromBackendJson)
            .toList()
        : <ProductVariant>[];

    return ProductModel(
      id: json['id']?.toString(),
      title: json['title'] as String? ?? '',
      brandName: json['brandName'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      priceAfetDiscount: (json['priceAfetDiscount'] as num?)?.toDouble(),
      dicountpercent: json['dicountpercent'] as int?,
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName']?.toString(),
      stockQuantity: json['stockQuantity'] is int
          ? json['stockQuantity'] as int
          : json['stockQuantity'] is String
              ? int.tryParse(json['stockQuantity'] as String)
              : null,
      imageUrls: images,
      variants: variants,
    );
  }

  factory ProductModel.fromBackendJson(Map<String, dynamic> json) {
    final imageUrlsRaw = json['image_urls'];
    final images = <String>[];

    if (imageUrlsRaw is List) {
      images.addAll(imageUrlsRaw.map((item) => item.toString()));
    } else if (imageUrlsRaw is String && imageUrlsRaw.isNotEmpty) {
      images.add(imageUrlsRaw);
    }

    final variantsJson = json['variants'];
    final variants = variantsJson is List
        ? variantsJson
            .whereType<Map<String, dynamic>>()
            .map(ProductVariant.fromBackendJson)
            .toList()
        : <ProductVariant>[];

    final cartItemId = json['id']?.toString();
    final productId = json['product_id']?.toString() ?? cartItemId;
    final cartQuantity = json['quantity'] is int
        ? json['quantity'] as int
        : json['quantity'] is String
            ? int.tryParse(json['quantity'] as String)
            : null;

    return ProductModel(
      id: productId,
      cartItemId: cartItemId,
      cartQuantity: cartQuantity,
      title: json['name']?.toString() ?? '',
      brandName: json['brand_name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: (json['price'] is String
                  ? double.tryParse(json['price'] as String)
                  : json['price'] as num?)
              ?.toDouble() ??
          0,
      priceAfetDiscount: (json['price_after_discount'] is String
              ? double.tryParse(json['price_after_discount'] as String)
              : json['price_after_discount'] as num?)
          ?.toDouble(),
      dicountpercent: json['discount_percent'] is int
          ? json['discount_percent'] as int
          : null,
      categoryId: json['category_id']?.toString(),
      categoryName: json['category_name']?.toString(),
      stockQuantity: json['stock_quantity'] is int
          ? json['stock_quantity'] as int
          : json['stock_quantity'] is String
              ? int.tryParse(json['stock_quantity'] as String)
              : null,
      imageUrls: images,
      variants: variants,
    );
  }

  ProductModel copyWith({
    String? id,
    String? cartItemId,
    int? cartQuantity,
    String? title,
    String? brandName,
    String? description,
    double? price,
    double? priceAfetDiscount,
    int? dicountpercent,
    String? categoryId,
    String? categoryName,
    int? stockQuantity,
    List<String>? imageUrls,
    List<ProductVariant>? variants,
  }) {
    return ProductModel(
      id: id ?? this.id,
      cartItemId: cartItemId ?? this.cartItemId,
      cartQuantity: cartQuantity ?? this.cartQuantity,
      title: title ?? this.title,
      brandName: brandName ?? this.brandName,
      description: description ?? this.description,
      price: price ?? this.price,
      priceAfetDiscount: priceAfetDiscount ?? this.priceAfetDiscount,
      dicountpercent: dicountpercent ?? this.dicountpercent,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrls: imageUrls ?? this.imageUrls,
      variants: variants ?? this.variants,
    );
  }
}

const List<ProductModel> demoPopularProducts = [
  ProductModel(
    imageUrls: [productDemoImg1],
    title: "Mountain Warehouse for Women",
    brandName: "Lipsy london",
    price: 540,
    priceAfetDiscount: 420,
    dicountpercent: 20,
  ),
  ProductModel(
    imageUrls: [productDemoImg4],
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 800,
  ),
  ProductModel(
    imageUrls: [productDemoImg5],
    title: "FS - Nike Air Max 270 Really React",
    brandName: "Lipsy london",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
  ),
  ProductModel(
    imageUrls: [productDemoImg6],
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
  ),
  ProductModel(
    imageUrls: ["https://i.imgur.com/tXyOMMG.png"],
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
  ),
  ProductModel(
    imageUrls: ["https://i.imgur.com/h2LqppX.png"],
    title: "white satin corset top",
    brandName: "Lipsy london",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
  ),
];
const List<ProductModel> demoFlashSaleProducts = [
  ProductModel(
    imageUrls: [productDemoImg5],
    title: "FS - Nike Air Max 270 Really React",
    brandName: "Lipsy london",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
  ),
  ProductModel(
    imageUrls: [productDemoImg6],
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
  ),
  ProductModel(
    imageUrls: [productDemoImg4],
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 800,
    priceAfetDiscount: 680,
    dicountpercent: 15,
  ),
];
const List<ProductModel> demoBestSellersProducts = [
  ProductModel(
    imageUrls: ["https://i.imgur.com/tXyOMMG.png"],
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
  ),
  ProductModel(
    imageUrls: ["https://i.imgur.com/h2LqppX.png"],
    title: "white satin corset top",
    brandName: "Lipsy london",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
  ),
  ProductModel(
    imageUrls: [productDemoImg4],
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 800,
    priceAfetDiscount: 680,
    dicountpercent: 15,
  ),
];
const List<ProductModel> kidsProducts = [
  ProductModel(
    imageUrls: ["https://i.imgur.com/dbbT6PA.png"],
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 650.62,
    priceAfetDiscount: 590.36,
    dicountpercent: 24,
  ),
  ProductModel(
    imageUrls: ["https://i.imgur.com/7fSxC7k.png"],
    title: "Printed Sleeveless Tiered Swing Dress",
    brandName: "Lipsy london",
    price: 650.62,
  ),
  ProductModel(
    imageUrls: ["https://i.imgur.com/pXnYE9Q.png"],
    title: "Ruffle-Sleeve Ponte-Knit Sheath ",
    brandName: "Lipsy london",
    price: 400,
  ),
  ProductModel(
    imageUrls: ["https://i.imgur.com/V1MXgfa.png"],
    title: "Green Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 400,
    priceAfetDiscount: 360,
    dicountpercent: 20,
  ),
  ProductModel(
    imageUrls: ["https://i.imgur.com/8gvE5Ss.png"],
    title: "Printed Sleeveless Tiered Swing Dress",
    brandName: "Lipsy london",
    price: 654,
  ),
  ProductModel(
    imageUrls: ["https://i.imgur.com/cBvB5YB.png"],
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 250,
  ),
];
