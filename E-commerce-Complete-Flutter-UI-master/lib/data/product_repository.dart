import 'package:shop/config/app_config.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/api_client.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getPopularProducts();
  Future<List<ProductModel>> getFlashSaleProducts();
  Future<List<ProductModel>> getBestSellerProducts();
  Future<List<ProductModel>> getKidsProducts();
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> searchProducts(
      {String? query, String? categoryId});
  Future<List<ProductModel>> getStoreProducts(String brandName);
}

class DemoProductRepository implements ProductRepository {
  @override
  Future<List<ProductModel>> getPopularProducts() async {
    if (!AppConfig.current.useDemoData) {
      final rawProducts = await ApiClient.getList('/api/products?limit=12');
      return rawProducts
          .map((item) =>
              ProductModel.fromBackendJson(item as Map<String, dynamic>))
          .toList();
    }

    return demoPopularProducts;
  }

  @override
  Future<List<ProductModel>> getFlashSaleProducts() async {
    if (!AppConfig.current.useDemoData) {
      final rawProducts =
          await ApiClient.getList('/api/products?limit=12&sort_by=price_asc');
      return rawProducts
          .map((item) =>
              ProductModel.fromBackendJson(item as Map<String, dynamic>))
          .toList();
    }

    return demoFlashSaleProducts;
  }

  @override
  Future<List<ProductModel>> getBestSellerProducts() async {
    if (!AppConfig.current.useDemoData) {
      final rawProducts =
          await ApiClient.getList('/api/products?limit=12&sort_by=newest');
      return rawProducts
          .map((item) =>
              ProductModel.fromBackendJson(item as Map<String, dynamic>))
          .toList();
    }

    return demoBestSellersProducts;
  }

  @override
  Future<List<ProductModel>> getKidsProducts() async {
    if (!AppConfig.current.useDemoData) {
      final rawProducts = await ApiClient.getList('/api/products?limit=12');
      return rawProducts
          .map((item) =>
              ProductModel.fromBackendJson(item as Map<String, dynamic>))
          .toList();
    }

    return kidsProducts;
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    if (!AppConfig.current.useDemoData) {
      final rawProduct = await ApiClient.getJson('/api/products/$id');
      return ProductModel.fromBackendJson(rawProduct);
    }

    return demoPopularProducts.first;
  }

  @override
  Future<List<ProductModel>> searchProducts(
      {String? query, String? categoryId}) async {
    if (AppConfig.current.useDemoData) return demoPopularProducts;
    final parameters = <String, String>{'limit': '30'};
    if (query != null && query.trim().isNotEmpty)
      parameters['search'] = query.trim();
    if (categoryId != null && categoryId.trim().isNotEmpty) {
      parameters['category_id'] = categoryId.trim();
    }
    final uri = Uri(queryParameters: parameters).query;
    final rawProducts = await ApiClient.getList('/api/products?$uri');
    return rawProducts
        .map((item) =>
            ProductModel.fromBackendJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProductModel>> getStoreProducts(String brandName) async {
    if (AppConfig.current.useDemoData) return demoPopularProducts;
    final encodedBrand = Uri.encodeQueryComponent(brandName);
    final rawProducts = await ApiClient.getList(
        '/api/products?brand_name=$encodedBrand&limit=50&sort_by=newest');
    return rawProducts
        .map((item) =>
            ProductModel.fromBackendJson(item as Map<String, dynamic>))
        .toList();
  }
}
