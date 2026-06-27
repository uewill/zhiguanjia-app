import 'package:get/get.dart';
import '../../../../app/core/data/index.dart';
import '../models/product_model_new.dart';

/// 商品管理控制器 - 使用抽象框架
class ProductControllerNew extends DataController<ProductModel> {
  @override
  DataPageConfig get config => DataPageConfig.product;

  @override
  ProductModel fromJson(Map<String, dynamic> json) => 
      ProductModel.fromJson(json);

  @override
  List<ProductModel> getMockData() => [
    ProductModel(
      id: 1,
      name: '百事可乐330ml',
      code: 'SP001',
      barcode: '6901234567890',
      categoryId: '1',
      categoryName: '饮料',
      unit: '罐',
      purchasePrice: 2.50,
      salePrice: 3.50,
      stock: 100,
      minStock: 20,
    ),
    ProductModel(
      id: 2,
      name: '可口可乐330ml',
      code: 'SP002',
      barcode: '6901234567891',
      categoryId: '1',
      categoryName: '饮料',
      unit: '罐',
      purchasePrice: 2.50,
      salePrice: 3.50,
      stock: 50,
      minStock: 20,
    ),
    ProductModel(
      id: 3,
      name: '康师傅红烧牛肉面',
      code: 'SP003',
      barcode: '6901234567892',
      categoryId: '2',
      categoryName: '方便面',
      unit: '袋',
      purchasePrice: 3.00,
      salePrice: 4.50,
      stock: 200,
      minStock: 30,
    ),
  ];

  /// 获取库存预警商品
  List<ProductModel> getLowStockProducts() {
    return items.where((p) => p.isLowStock).toList();
  }

  /// 按分类筛选
  List<ProductModel> getProductsByCategory(String categoryId) {
    return items.where((p) => p.categoryId == categoryId).toList();
  }

  /// 获取所有分类
  List<Map<String, String>> getCategories() {
    final categories = <Map<String, String>>[];
    final seen = <String>{};
    for (var product in items) {
      if (product.categoryId != null && 
          product.categoryName != null &&
          !seen.contains(product.categoryId)) {
        seen.add(product.categoryId!);
        categories.add({
          'id': product.categoryId!,
          'name': product.categoryName!,
        });
      }
    }
    return categories;
  }
}