import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/customer_model.dart';
import '../../../services/api_service.dart';

class CustomerController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  var customers = <Customer>[].obs;
  var isLoading = false.obs;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/customers');
      if (response.data['code'] == 200) {
        customers.value = (response.data['data'] as List)
            .map((e) => Customer.fromJson(e))
            .toList();
      }
    } catch (e) {
      Get.snackbar('错误', '加载客户失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCustomer(Map<String, dynamic> data) async {
    try {
      await _apiService.post('/customers', data: data);
      loadCustomers();
    } catch (e) {
      Get.snackbar('错误', '创建失败: $e');
    }
  }
}
