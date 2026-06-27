import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/api_service.dart';

class PurchaseController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  var isCreating = false.obs;
  
  var selectedSupplier = Rxn<Map<String, dynamic>>();
  var items = <Map<String, dynamic>>[].obs;
  var totalAmount = 0.0.obs;
  
  TextEditingController remarkController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    ever(items, (_) => calculateTotal());
  }

  void calculateTotal() {
    totalAmount.value = items.fold(0.0, (sum, item) => sum + (item['amount'] as double));
  }

  void selectSupplier(Map<String, dynamic> supplier) {
    selectedSupplier.value = supplier;
  }

  void addItem(Map<String, dynamic> item) {
    items.add(item);
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  Future<void> createPurchase() async {
    if (selectedSupplier.value == null) {
      Get.snackbar('提示', '请选择供应商');
      return;
    }
    if (items.isEmpty) {
      Get.snackbar('提示', '请添加商品');
      return;
    }

    isCreating.value = true;
    try {
      await _apiService.post('/purchases', data: {
        'supplierId': selectedSupplier.value!['id'],
        'items': items,
        'totalAmount': totalAmount.value,
        'remark': remarkController.text,
      });
      Get.back();
      Get.snackbar('成功', '入库成功');
    } catch (e) {
      Get.snackbar('错误', '入库失败: $e');
    } finally {
      isCreating.value = false;
    }
  }
}
