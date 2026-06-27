import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/order_model.dart';
import '../../../services/api_service.dart';

class OrderController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Tab状态
  final selectedTab = 0.obs;
  final tabs = ['全部', '待审核', '待入库', '已完成', '已取消'];

  // 数据
  final orders = <Order>[].obs;
  final filteredOrders = <Order>[].obs;
  final isLoading = false.obs;

  // 搜索
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  void changeTab(int index) {
    selectedTab.value = index;
    _filterOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      orders.value = _getMockOrders();
      _filterOrders();
    } finally {
      isLoading.value = false;
    }
  }

  void _filterOrders() {
    var result = orders;

    if (selectedTab.value > 0) {
      final statusMap = {
        1: 0, // 待审核
        2: 1, // 待入库
        3: 3, // 已完成
        4: 4, // 已取消
      };
      final targetStatus = statusMap[selectedTab.value];
      result = result.where((o) => o.status == targetStatus).toList().obs;
    }

    if (searchController.text.isNotEmpty) {
      final keyword = searchController.text.toLowerCase();
      result = result.where((o) =>
        o.orderNo.toLowerCase().contains(keyword) ||
        o.customerName.toLowerCase().contains(keyword)
      ).toList().obs;
    }

    filteredOrders.value = result;
  }

  void search(String keyword) {
    _filterOrders();
  }

  void createOrder() {
    Get.toNamed('/orders/create');
  }

  void viewDetail(Order order) {
    Get.toNamed('/orders/detail', arguments: order);
  }

  void cancelOrder(int id) {
    _showToast('订单已取消');
    loadOrders();
    Get.back();
  }

  void completeOrder(int id) {
    _showToast('订单已完成');
    loadOrders();
    Get.back();
  }

  List<Order> _getMockOrders() {
    return [
      Order(
        id: 1,
        orderNo: 'PO2024010001',
        type: 'purchase',
        customerId: 1,
        customerName: '可口可乐供应商',
        items: [],
        totalAmount: 2800,
        discountAmount: 0,
        status: 0,
        createTime: DateTime(2024, 1, 1),
      ),
      Order(
        id: 2,
        orderNo: 'SO2024010002',
        type: 'sale',
        customerId: 2,
        customerName: '张三客户',
        items: [],
        totalAmount: 1200,
        discountAmount: 0,
        status: 3,
        createTime: DateTime(2024, 1, 1),
      ),
      Order(
        id: 3,
        orderNo: 'PO2024010003',
        type: 'purchase',
        customerId: 3,
        customerName: '红牛供应商',
        items: [],
        totalAmount: 3500,
        discountAmount: 0,
        status: 1,
        createTime: DateTime(2024, 1, 2),
      ),
      Order(
        id: 4,
        orderNo: 'SO2024010004',
        type: 'sale',
        customerId: 4,
        customerName: '李四客户',
        items: [],
        totalAmount: 850,
        discountAmount: 0,
        status: 0,
        createTime: DateTime(2024, 1, 2),
      ),
      Order(
        id: 5,
        orderNo: 'PO2024010005',
        type: 'purchase',
        customerId: 5,
        customerName: '泡面供应商',
        items: [],
        totalAmount: 1200,
        discountAmount: 0,
        status: 4,
        createTime: DateTime(2024, 1, 3),
      ),
    ];
  }

  String getStatusText(int status) {
    switch (status) {
      case 0: return '待审核';
      case 1: return '已审核';
      case 2: return '部分入库';
      case 3: return '已完成';
      case 4: return '已取消';
      default: return '未知';
    }
  }

  Color getStatusColor(int status) {
    switch (status) {
      case 0: return const Color(0xFFFF7D00);
      case 1: return const Color(0xFF2FC27D);
      case 2: return Colors.blue;
      case 3: return const Color(0xFF00B42A);
      case 4: return const Color(0xFF86909C);
      default: return Colors.grey;
    }
  }

  void _showToast(String message) {
    if (Get.context != null) {
      TDToast.showText(message, context: Get.context!);
    }
  }
}
