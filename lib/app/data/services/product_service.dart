import '../../core/network/api_client.dart';
import '../models/product_model.dart';

/// 商品服务
class ProductService {
  final ApiClient _client = ApiClient();

  /// 获取商品列表
  Future<List<Product>> getProducts({
    String? keyword,
    int? categoryId,
    int page = 1,
    int size = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      path: '/products',
      queryParams: {
        if (keyword != null) 'keyword': keyword,
        if (categoryId != null) 'categoryId': categoryId.toString(),
        'page': page.toString(),
        'size': size.toString(),
      },
    );
    
    final List<dynamic> list = response['records'] ?? response['list'] ?? [];
    return list.map((e) => Product.fromJson(e)).toList();
  }

  /// 获取商品详情
  Future<Product> getProduct(int id) async {
    final response = await _client.get<Map<String, dynamic>>(
      path: '/products/$id',
    );
    return Product.fromJson(response);
  }

  /// 创建商品
  Future<Product> createProduct(Product product) async {
    final response = await _client.post<Map<String, dynamic>>(
      path: '/products',
      body: product.toJson(),
    );
    return Product.fromJson(response);
  }

  /// 更新商品
  Future<Product> updateProduct(Product product) async {
    final response = await _client.put<Map<String, dynamic>>(
      path: '/products/${product.id}',
      body: product.toJson(),
    );
    return Product.fromJson(response);
  }

  /// 删除商品
  Future<void> deleteProduct(int id) async {
    await _client.delete(path: '/products/$id');
  }

  /// 获取商品分类列表
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _client.get<List<dynamic>>(path: '/product-categories');
    return response.cast<Map<String, dynamic>>();
  }

  /// 获取商品库存
  Future<List<Map<String, dynamic>>> getProductStock(int productId) async {
    final response = await _client.get<List<dynamic>>(
      path: '/products/$productId/stock',
    );
    return response.cast<Map<String, dynamic>>();
  }
}
