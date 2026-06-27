import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../views/inventory_transfer_view.dart';
import '../views/stock_check_view.dart';

class InventoryController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Tab状态
  final selectedTab = 0.obs;
  final tabs = ['库存查询', '库存调拨', '库存盘点', '库存预警'];
  
  // 加载状态
  final isLoading = false.obs;
  
  // 库存列表数据
  final inventoryList = <Map<String, dynamic>>[].obs;
  final filteredInventory = <Map<String, dynamic>>[].obs;
  
  // 搜索
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadInventory();
  }

  void changeTab(int index) {
    selectedTab.value = index;
    if (index == 0) {
      loadInventory();
    }
  }

  Future<void> loadInventory() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      inventoryList.value = [
        {'name': '可乐', 'warehouse': '主仓', 'quantity': 136, 'locked': 10, 'available': 126, 'warning': false},
        {'name': '红牛', 'warehouse': '主仓', 'quantity': 80, 'locked': 0, 'available': 80, 'warning': false},
        {'name': '泡面', 'warehouse': '主仓', 'quantity': 50, 'locked': 0, 'available': 50, 'warning': true},
        {'name': '矿泉水', 'warehouse': '主仓', 'quantity': 25, 'locked': 5, 'available': 20, 'warning': true},
        {'name': '薯片', 'warehouse': '主仓', 'quantity': 200, 'locked': 0, 'available': 200, 'warning': false},
      ];
      _filterInventory();
    } finally {
      isLoading.value = false;
    }
  }

  void _filterInventory() {
    if (searchController.text.isEmpty) {
      filteredInventory.value = inventoryList;
    } else {
      final keyword = searchController.text.toLowerCase();
      filteredInventory.value = inventoryList
          .where((item) => item['name'].toString().toLowerCase().contains(keyword))
          .toList();
    }
  }

  void search(String keyword) {
    _filterInventory();
  }

  void showAdjustDialog(Map<String, dynamic> item) {
    Get.dialog(
      AlertDialog(
        title: const Text('库存调整'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('商品: ${item['name']}'),
            const SizedBox(height: 16),
              TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '调整后数量',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: '调整原因',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('成功', '库存调整已提交');
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void transferStock() {
    Get.to(() => const InventoryTransferView());
  }

  void checkStock() {
    Get.to(() => const StockCheckView());
  }
}
