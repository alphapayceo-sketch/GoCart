import 'package:flutter/foundation.dart';

@immutable
class CategoryModel {
  final String? id;
  final String title;
  final String? image;
  final String? svgSrc;
  final List<CategoryModel>? subCategories;

  const CategoryModel({
    this.id,
    required this.title,
    this.image,
    this.svgSrc,
    this.subCategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      title: json['title'] as String? ?? '',
      image: json['image'] as String?,
      svgSrc: json['svgSrc'] as String?,
      subCategories: (json['subCategories'] as List<dynamic>?)
          ?.map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  factory CategoryModel.fromBackendJson(Map<String, dynamic> json) {
    final subCategories = (json['sub_categories'] as List<dynamic>?)
        ?.map((item) =>
            CategoryModel.fromBackendJson(item as Map<String, dynamic>))
        .toList();

    return CategoryModel(
      id: json['id']?.toString(),
      title: json['name']?.toString() ?? json['title']?.toString() ?? '',
      image: json['image_url']?.toString() ?? json['image']?.toString(),
      svgSrc: json['svgSrc']?.toString(),
      subCategories: subCategories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'image': image,
      'svgSrc': svgSrc,
      'subCategories': subCategories?.map((item) => item.toJson()).toList(),
    };
  }

  CategoryModel copyWith({
    String? title,
    String? image,
    String? svgSrc,
    List<CategoryModel>? subCategories,
  }) {
    return CategoryModel(
      title: title ?? this.title,
      image: image ?? this.image,
      svgSrc: svgSrc ?? this.svgSrc,
      subCategories: subCategories ?? this.subCategories,
    );
  }
}

const List<CategoryModel> demoCategoriesWithImage = [
  CategoryModel(title: "Woman’s", image: "https://i.imgur.com/5M89G2P.png"),
  CategoryModel(title: "Man’s", image: "https://i.imgur.com/UM3GdWg.png"),
  CategoryModel(title: "Kid’s", image: "https://i.imgur.com/Lp0D6k5.png"),
  CategoryModel(title: "Accessories", image: "https://i.imgur.com/3mSE5sN.png"),
];

const List<CategoryModel> demoCategories = [
  CategoryModel(
    title: "On sale",
    svgSrc: "assets/icons/Sale.svg",
    subCategories: [
      CategoryModel(title: "All Clothing"),
      CategoryModel(title: "New In"),
      CategoryModel(title: "Coats & Jackets"),
      CategoryModel(title: "Dresses"),
      CategoryModel(title: "Jeans"),
    ],
  ),
  CategoryModel(
    title: "Man’s & Woman’s",
    svgSrc: "assets/icons/Man&Woman.svg",
    subCategories: [
      CategoryModel(title: "All Clothing"),
      CategoryModel(title: "New In"),
      CategoryModel(title: "Coats & Jackets"),
    ],
  ),
  CategoryModel(
    title: "Kids",
    svgSrc: "assets/icons/Child.svg",
    subCategories: [
      CategoryModel(title: "All Clothing"),
      CategoryModel(title: "New In"),
      CategoryModel(title: "Coats & Jackets"),
    ],
  ),
  CategoryModel(
    title: "Accessories",
    svgSrc: "assets/icons/Accessories.svg",
    subCategories: [
      CategoryModel(title: "All Clothing"),
      CategoryModel(title: "New In"),
    ],
  ),
];
