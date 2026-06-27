import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class OrderListController extends GetxController {
  final orders = <dynamic>[].obs;
  final isLoading = false.obs;
  final selectedStatus = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      final response = await Get.find<ApiService>().get(
        '/orders',
        queryParameters: selectedStatus.value != null
            ? {'status': selectedStatus.value}
            : null,
      );
      if (response.data['code'] == 200) {
        orders.value = response.data['data'] ?? [];
      }
    } catch (e) {
      Get.snackbar('错误', '加载订单失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterByStatus(int? status) {
    selectedStatus.value = status;
    loadOrders();
  }

  String getStatusText(int? status) {
    switch (status) {
      case 0:
        return '待处理';
      case 1:
        return '已确认';
      case 2:
        return '已完成';
      case 3:
        return '已取消';
      default:
        return '未知';
    }
  }

  Color getStatusColor(int? status) {
    switch (status) {
      case 0:
        return const Color(0xFFFF7D00);
      case 1:
        return const Color(0xFF0052D9);
      case 2:
        return const Color(0xFF00A870);
      case 3:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
