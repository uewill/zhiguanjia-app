import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../services/api_service.dart';

class ProductController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  var products = <Product>[].obs;
  var filteredProducts = <Product>[].obs;
  var isLoading = false.obs;
  var searchKeyword = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    ever(searchKeyword, (_) => filterProducts());
  }

  void filterProducts() {
    if (searchKeyword.value.isEmpty) {
      filteredProducts.value = products;
    } else {
      filteredProducts.value = products
          .where((p) => p.name.toLowerCase().contains(searchKeyword.value.toLowerCase()))
          .toList();
    }
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/products');
      if (response.data['code'] == 200) {
        products.value = (response.data['data'] as List)
            .map((e) => Product.fromJson(e))
            .toList();
        filteredProducts.value = products;
      }
    } catch (e) {
      Get.snackbar('错误', '加载商品失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _apiService.delete('/products/$id');
      products.removeWhere((p) => p.id == id);
      filterProducts();
      Get.snackbar('成功', '商品已删除');
    } catch (e) {
      Get.snackbar('错误', '删除失败: $e');
    }
  }

  void searchProducts(String keyword) {
    searchKeyword.value = keyword;
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    try {
      await _apiService.post('/products', data: data);
      loadProducts();
      Get.snackbar('成功', '商品创建成功');
    } catch (e) {
      Get.snackbar('错误', '创建失败: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      await _apiService.put('/products/$id', data: data);
      loadProducts();
      Get.snackbar('成功', '商品更新成功');
    } catch (e) {
      Get.snackbar('错误', '更新失败: $e');
      rethrow;
    }
  }
}
