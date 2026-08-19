import 'package:shop/config/app_config.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/services/api_client.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();
  Future<List<CategoryModel>> getCategoryCards();
}

class DemoCategoryRepository implements CategoryRepository {
  @override
  Future<List<CategoryModel>> getCategories() async {
    if (!AppConfig.current.useDemoData) {
      try {
        final rawCategories =
            await ApiClient.getList('/api/products/categories');
        return rawCategories
            .map((item) =>
                CategoryModel.fromBackendJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return const [];
      }
    }

    return demoCategories;
  }

  @override
  Future<List<CategoryModel>> getCategoryCards() async {
    if (!AppConfig.current.useDemoData) {
      try {
        final rawCategories =
            await ApiClient.getList('/api/products/categories');
        return rawCategories
            .map((item) =>
                CategoryModel.fromBackendJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return const [];
      }
    }

    return demoCategoriesWithImage;
  }
}
