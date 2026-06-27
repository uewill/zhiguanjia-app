import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../data/models/warning_model.dart';
import '../../../services/warning_service.dart';

class WarningController extends GetxController {
  final WarningService _warningService = Get.find<WarningService>();

  // 预警列表
  final warningList = <InventoryWarning>[].obs;
  final filteredWarnings = <InventoryWarning>[].obs;
  final isLoading = false.obs;

  // 筛选
  final selectedType = 0.obs; // 0=全部
  final showRead = false.obs;

  // 统计
  final unreadCount = 0.obs;

  // 预警设置
  final minStockController = TextEditingController();
  final maxStockController = TextEditingController();
  final expiryDaysController = TextEditingController();
  final stagnantDaysController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadWarnings();
    loadUnreadCount();
  }

  Future<void> loadWarnings() async {
    isLoading.value = true;
    try {
      warningList.value = await _warningService.getWarningList(
        type: selectedType.value == 0 ? null : selectedType.value,
        isRead: showRead.value ? null : false,
      );
      _filterWarnings();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUnreadCount() async {
    unreadCount.value = await _warningService.getUnreadCount();
  }

  void onTypeChanged(int? type) {
    selectedType.value = type ?? 0;
    loadWarnings();
  }

  void toggleShowRead() {
    showRead.value = !showRead.value;
    loadWarnings();
  }

  void _filterWarnings() {
    var result = warningList;

    // 类型筛选
    if (selectedType.value > 0) {
      result = result.where((w) => w.warningType == selectedType.value).toList().obs;
    }

    filteredWarnings.value = result;
  }

  Future<void> markAsRead(String warningId) async {
    final success = await _warningService.markAsRead(warningId);
    if (success) {
      final index = warningList.indexWhere((w) => w.id == warningId);
      if (index != -1) {
        final updated = warningList[index];
        warningList[index] = InventoryWarning(
          id: updated.id,
          productId: updated.productId,
          productName: updated.productName,
          skuSpec: updated.skuSpec,
          warningType: updated.warningType,
          warningTypeName: updated.warningTypeName,
          currentStock: updated.currentStock,
          thresholdValue: updated.thresholdValue,
          warehouseName: updated.warehouseName,
          isRead: true,
          createTime: updated.createTime,
        );
        warningList.refresh();
      }
      loadUnreadCount();
    }
  }

  Future<void> markAllAsRead() async {
    final success = await _warningService.markAllAsRead();
    if (success) {
      for (var i = 0; i < warningList.length; i++) {
        final w = warningList[i];
        warningList[i] = InventoryWarning(
          id: w.id,
          productId: w.productId,
          productName: w.productName,
          skuSpec: w.skuSpec,
          warningType: w.warningType,
          warningTypeName: w.warningTypeName,
          currentStock: w.currentStock,
          thresholdValue: w.thresholdValue,
          warehouseName: w.warehouseName,
          isRead: true,
          createTime: w.createTime,
        );
      }
      warningList.refresh();
      unreadCount.value = 0;
      _showToast('已标记所有为已读');
    }
  }

  Future<void> deleteWarning(String warningId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('是否删除该预警？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _warningService.deleteWarning(warningId);
      if (success) {
        warningList.removeWhere((w) => w.id == warningId);
        _filterWarnings();
        _showToast('删除成功');
      } else {
        _showToast('删除失败');
      }
    }
  }

  // 跳转到相关单据或商品
  void goToRelatedItem(InventoryWarning warning) {
    switch (warning.warningType) {
      case WarningType.lowStock:
      case WarningType.highStock:
      case WarningType.stagnant:
        Get.toNamed('/inventory/detail', arguments: warning.productId);
        break;
      case WarningType.expiry:
        Get.toNamed('/inventory/check');
        break;
    }
  }

  // 跳转到预警设置
  void goToSettings() {
    Get.toNamed('/warning/settings');
  }

  void _showToast(String message) {
    if (Get.context != null) {
      TDToast.showText(message, context: Get.context!);
    }
  }

  @override
  void onClose() {
    minStockController.dispose();
    maxStockController.dispose();
    expiryDaysController.dispose();
    stagnantDaysController.dispose();
    super.onClose();
  }
}
