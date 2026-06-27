import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/supplier_model.dart';
import '../../../services/api_service.dart';

class SupplierController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var suppliers = <Supplier>[].obs;
  var isLoading = false.obs;

  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      suppliers.value = _getMockSuppliers();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSupplier(Map<String, dynamic> data) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      loadSuppliers();
      Get.snackbar('成功', '保存成功');
    } catch (e) {
      Get.snackbar('错误', '创建失败: $e');
    }
  }

  List<Supplier> _getMockSuppliers() {
    return [
      Supplier(id: 1, name: '可口可乐供应商', contact: '张经理', phone: '13800138001'),
      Supplier(id: 2, name: '红牛供应商', contact: '李经理', phone: '13800138002'),
      Supplier(id: 3, name: '泡面供应商', contact: '王经理', phone: '13800138003'),
      Supplier(id: 4, name: '饭团供应商', contact: '赵经理', phone: '13800138004'),
    ];
  }
}
