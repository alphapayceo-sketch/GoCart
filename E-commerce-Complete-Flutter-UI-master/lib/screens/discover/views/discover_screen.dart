import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/category_repository.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/screens/search/views/components/search_form.dart';

import 'components/expansion_category.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  static final CategoryRepository _repository = DemoCategoryRepository();
  late final Future<List<CategoryModel>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _repository.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: SearchForm(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding / 2),
              child: Text(
                "Categories",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<CategoryModel>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  final categories = snapshot.data ?? const <CategoryModel>[];

                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) => ExpansionCategory(
                      svgSrc: categories[index].svgSrc ?? '',
                      title: categories[index].title,
                      subCategory: categories[index].subCategories ?? const [],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
