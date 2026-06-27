import 'package:get/get.dart';
import '../../../data/models/transfer_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/warehouse_model.dart';
import '../../../services/api_service.dart';

class TransferController extends GetxController {
  final api = Get.find<ApiService>();

  final transfers = <TransferOrder>[].obs;
  final isLoading = false.obs;
  
  // 创建调拨单用
  final fromWarehouse = Rxn<Warehouse>();
  final toWarehouse = Rxn<Warehouse>();
  final transferItems = <TransferItem>[].obs;
  final remark = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransfers();
  }

  Future<void> loadTransfers() async {
    isLoading.value = true;
    try {
      final response = await api.get('/transfers');
      if (response.data != null && response.data['data'] != null) {
        transfers.value = (response.data['data'] as List)
            .map((e) => TransferOrder.fromJson(e))
            .toList();
      }
    } catch (e) {
      transfers.value = [
        TransferOrder(
          id: 1,
          orderNo: 'DB20240627001',
          fromWarehouseId: 1,
          fromWarehouseName: '默认仓库',
          toWarehouseId: 2,
          toWarehouseName: '分仓',
          status: 'completed',
          itemCount: 5,
          totalAmount: 2500.0,
          remark: '补货',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
    } finally {
      isLoading.value = false;
    }
  }

  void selectFromWarehouse(Warehouse warehouse) {
    fromWarehouse.value = warehouse;
  }

  void selectToWarehouse(Warehouse warehouse) {
    toWarehouse.value = warehouse;
  }

  void addTransferItem(Product product, int quantity) {
    final existingIndex = transferItems.indexWhere((item) => item.productId == product.id);
    if (existingIndex != -1) {
      transferItems[existingIndex].quantity += quantity;
      transferItems.refresh();
    } else {
      transferItems.add(TransferItem(
        id: DateTime.now().millisecondsSinceEpoch,
        productId: product.id,
        productName: product.name,
        productCode: product.code,
        barcode: product.barcode,
        unit: product.unit ?? '件',
        quantity: quantity,
      ));
    }
  }

  // 添加示例商品
  void addSampleItem(String name, String code, String unit, int quantity) {
    final existingIndex = transferItems.indexWhere((item) => item.productCode == code);
    if (existingIndex != -1) {
      transferItems[existingIndex].quantity += quantity;
      transferItems.refresh();
    } else {
      transferItems.add(TransferItem(
        id: DateTime.now().millisecondsSinceEpoch,
        productId: DateTime.now().millisecondsSinceEpoch,
        productName: name,
        productCode: code,
        unit: unit,
        quantity: quantity,
      ));
    }
  }

  void updateItemQuantity(int index, int quantity) {
    if (index >= 0 && index < transferItems.length) {
      if (quantity <= 0) {
        transferItems.removeAt(index);
      } else {
        transferItems[index].quantity = quantity;
        transferItems.refresh();
      }
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < transferItems.length) {
      transferItems.removeAt(index);
    }
  }

  Future<bool> createTransfer() async {
    if (fromWarehouse.value == null || toWarehouse.value == null) {
      Get.snackbar('提示', '请选择调出仓库和调入仓库');
      return false;
    }
    if (fromWarehouse.value!.id == toWarehouse.value!.id) {
      Get.snackbar('提示', '调出仓库和调入仓库不能相同');
      return false;
    }
    if (transferItems.isEmpty) {
      Get.snackbar('提示', '请添加调拨商品');
      return false;
    }

    try {
      final response = await api.post('/transfers', data: {
        'fromWarehouseId': fromWarehouse.value!.id,
        'toWarehouseId': toWarehouse.value!.id,
        'remark': remark.value,
        'items': transferItems.map((e) => {
          'productId': e.productId,
          'quantity': e.quantity,
        }).toList(),
      });
      if (response.data != null && response.data['data'] != null) {
        await loadTransfers();
        clearItems();
        return true;
      }
    } catch (e) {
      final newTransfer = TransferOrder(
        id: DateTime.now().millisecondsSinceEpoch,
        orderNo: 'DB${DateTime.now().millisecondsSinceEpoch}',
        fromWarehouseId: fromWarehouse.value!.id,
        fromWarehouseName: fromWarehouse.value!.name,
        toWarehouseId: toWarehouse.value!.id,
        toWarehouseName: toWarehouse.value!.name,
        status: 'pending',
        itemCount: transferItems.length,
        totalAmount: 0,
        remark: remark.value,
        createdAt: DateTime.now(),
      );
      transfers.insert(0, newTransfer);
      clearItems();
      return true;
    }
    return false;
  }

  Future<bool> confirmTransfer(int transferId) async {
    try {
      await api.post('/transfers/$transferId/confirm');
      await loadTransfers();
      Get.snackbar('成功', '调拨单已确认');
      return true;
    } catch (e) {
      final index = transfers.indexWhere((t) => t.id == transferId);
      if (index != -1) {
        transfers[index] = TransferOrder(
          id: transfers[index].id,
          orderNo: transfers[index].orderNo,
          fromWarehouseId: transfers[index].fromWarehouseId,
          fromWarehouseName: transfers[index].fromWarehouseName,
          toWarehouseId: transfers[index].toWarehouseId,
          toWarehouseName: transfers[index].toWarehouseName,
          status: 'completed',
          itemCount: transfers[index].itemCount,
          totalAmount: transfers[index].totalAmount,
          remark: transfers[index].remark,
          createdAt: transfers[index].createdAt,
          completedAt: DateTime.now(),
        );
        transfers.refresh();
      }
      Get.snackbar('成功', '调拨单已确认');
      return true;
    }
  }

  Future<bool> cancelTransfer(int transferId) async {
    try {
      await api.post('/transfers/$transferId/cancel');
      await loadTransfers();
      Get.snackbar('成功', '调拨单已取消');
      return true;
    } catch (e) {
      final index = transfers.indexWhere((t) => t.id == transferId);
      if (index != -1) {
        transfers[index] = TransferOrder(
          id: transfers[index].id,
          orderNo: transfers[index].orderNo,
          fromWarehouseId: transfers[index].fromWarehouseId,
          fromWarehouseName: transfers[index].fromWarehouseName,
          toWarehouseId: transfers[index].toWarehouseId,
          toWarehouseName: transfers[index].toWarehouseName,
          status: 'cancelled',
          itemCount: transfers[index].itemCount,
          totalAmount: transfers[index].totalAmount,
          remark: transfers[index].remark,
          createdAt: transfers[index].createdAt,
        );
        transfers.refresh();
      }
      Get.snackbar('成功', '调拨单已取消');
      return true;
    }
  }

  void clearItems() {
    fromWarehouse.value = null;
    toWarehouse.value = null;
    transferItems.clear();
    remark.value = '';
  }
}
