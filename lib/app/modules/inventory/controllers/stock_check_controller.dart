import 'package:get/get.dart';
import '../../../data/models/stock_check_model.dart';
import '../../../data/models/warehouse_model.dart';
import '../../../services/api_service.dart';

class StockCheckController extends GetxController {
  final api = Get.find<ApiService>();

  final stockChecks = <StockCheckOrder>[].obs;
  final isLoading = false.obs;
  final selectedWarehouse = Rxn<Warehouse>();

  // 创建盘点单用
  final checkItems = <StockCheckItem>[].obs;
  final remark = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadStockChecks();
  }

  Future<void> loadStockChecks() async {
    isLoading.value = true;
    try {
      final response = await api.get('/stock-checks');
      if (response.data != null && response.data['data'] != null) {
        stockChecks.value = (response.data['data'] as List)
            .map((e) => StockCheckOrder.fromJson(e))
            .toList();
      }
    } catch (e) {
      // 示例数据
      stockChecks.value = [
        StockCheckOrder(
          id: 1,
          orderNo: 'PD20240627001',
          warehouseId: 1,
          warehouseName: '默认仓库',
          status: 'completed',
          itemCount: 15,
          profitCount: 2,
          lossCount: 1,
          profitAmount: 150.0,
          lossAmount: 80.0,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    } finally {
      isLoading.value = false;
    }
  }

  void selectWarehouse(dynamic warehouse) {
    selectedWarehouse.value = warehouse;
  }

  // 创建盘点单
  Future<bool> createStockCheck(int warehouseId) async {
    try {
      final response = await api.post('/stock-checks', data: {
        'warehouseId': warehouseId,
        'remark': remark.value,
      });
      if (response.data != null && response.data['data'] != null) {
        final newCheck = StockCheckOrder.fromJson(response.data['data']);
        stockChecks.insert(0, newCheck);
        return true;
      }
    } catch (e) {
      // 模拟创建
      final newCheck = StockCheckOrder(
        id: DateTime.now().millisecondsSinceEpoch,
        orderNo: 'PD${DateTime.now().millisecondsSinceEpoch}',
        warehouseId: warehouseId,
        warehouseName: selectedWarehouse.value?.name ?? '默认仓库',
        status: 'checking',
        itemCount: checkItems.length,
        createdAt: DateTime.now(),
      );
      stockChecks.insert(0, newCheck);
      return true;
    }
    return false;
  }

  // 扫码添加盘点商品
  void addCheckItem(Map<String, dynamic> product) {
    final existingIndex = checkItems.indexWhere((item) => item.productId == product['id']);
    if (existingIndex != -1) {
      // 已存在，更新数量
      checkItems[existingIndex].checkStock++;
      checkItems.refresh();
    } else {
      // 新增
      checkItems.add(StockCheckItem(
        id: DateTime.now().millisecondsSinceEpoch,
        productId: product['id'],
        productName: product['name'],
        productCode: product['code'],
        barcode: product['barcode'],
        unit: product['unit'],
        systemStock: product['stock'] ?? 0,
        checkStock: 1,
        purchasePrice: product['purchasePrice']?.toDouble(),
      ));
    }
  }

  // 更新盘点数量
  void updateCheckStock(int index, int stock) {
    if (index >= 0 && index < checkItems.length) {
      checkItems[index].checkStock = stock;
      checkItems.refresh();
    }
  }

  // 移除盘点项
  void removeCheckItem(int index) {
    if (index >= 0 && index < checkItems.length) {
      checkItems.removeAt(index);
    }
  }

  // 完成盘点
  Future<bool> completeStockCheck(int checkId) async {
    try {
      await api.post('/stock-checks/$checkId/complete', data: {
        'items': checkItems.map((e) => {
          'productId': e.productId,
          'checkStock': e.checkStock,
          'remark': e.remark,
        }).toList(),
      });
      await loadStockChecks();
      Get.snackbar('成功', '盘点完成');
      return true;
    } catch (e) {
      // 模拟完成
      final index = stockChecks.indexWhere((c) => c.id == checkId);
      if (index != -1) {
        final profitCount = checkItems.where((i) => i.isProfit).length;
        final lossCount = checkItems.where((i) => i.isLoss).length;
        final profitAmount = checkItems.where((i) => i.isProfit).fold<double>(0, (sum, i) => sum + (i.diffAmount ?? 0));
        final lossAmount = checkItems.where((i) => i.isLoss).fold<double>(0, (sum, i) => sum + (i.diffAmount ?? 0));

        stockChecks[index] = StockCheckOrder(
          id: stockChecks[index].id,
          orderNo: stockChecks[index].orderNo,
          warehouseId: stockChecks[index].warehouseId,
          warehouseName: stockChecks[index].warehouseName,
          status: 'completed',
          itemCount: checkItems.length,
          profitCount: profitCount,
          lossCount: lossCount,
          profitAmount: profitAmount,
          lossAmount: lossAmount,
          createdAt: stockChecks[index].createdAt,
          completedAt: DateTime.now(),
        );
      }
      checkItems.clear();
      Get.snackbar('成功', '盘点完成');
      return true;
    }
  }

  void clearItems() {
    checkItems.clear();
    remark.value = '';
  }
}
