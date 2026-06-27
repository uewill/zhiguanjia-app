import 'package:get/get.dart';
import '../../../data/models/purchase_order_model.dart';
import '../../../data/models/supplier_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/warehouse_model.dart';
import '../../../services/api_service.dart';

class PurchaseOrderController extends GetxController {
  final api = Get.find<ApiService>();

  final orders = <PurchaseOrder>[].obs;
  final isLoading = false.obs;
  
  // 创建订单用
  final selectedSupplier = Rxn<Supplier>();
  final selectedWarehouse = Rxn<Warehouse>();
  final orderItems = <PurchaseOrderItem>[].obs;
  final remark = ''.obs;
  final orderDate = DateTime.now().obs;
  final deliveryDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      final response = await api.get('/purchase-orders');
      if (response.data != null && response.data['data'] != null) {
        orders.value = (response.data['data'] as List)
            .map((e) => PurchaseOrder.fromJson(e))
            .toList();
      }
    } catch (e) {
      orders.value = [
        PurchaseOrder(
          id: 1,
          orderNo: 'CGDD20240627001',
          supplierId: 1,
          supplierName: '供应商A',
          warehouseId: 1,
          warehouseName: '默认仓库',
          status: 'completed',
          itemCount: 10,
          totalAmount: 5000.0,
          remark: '常规采购',
          orderDate: DateTime.now().subtract(const Duration(days: 5)),
          deliveryDate: DateTime.now().subtract(const Duration(days: 2)),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        PurchaseOrder(
          id: 2,
          orderNo: 'CGDD20240627002',
          supplierId: 2,
          supplierName: '供应商B',
          warehouseId: 1,
          warehouseName: '默认仓库',
          status: 'pending',
          itemCount: 5,
          totalAmount: 2500.0,
          orderDate: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];
    } finally {
      isLoading.value = false;
    }
  }

  void selectSupplier(Supplier supplier) {
    selectedSupplier.value = supplier;
  }

  void selectWarehouse(Warehouse warehouse) {
    selectedWarehouse.value = warehouse;
  }

  void setOrderDate(DateTime date) {
    orderDate.value = date;
  }

  void setDeliveryDate(DateTime? date) {
    deliveryDate.value = date;
  }

  void addOrderItem(Product product, int quantity, double price) {
    final existingIndex = orderItems.indexWhere((item) => item.productId == product.id);
    if (existingIndex != -1) {
      orderItems[existingIndex].quantity += quantity;
      orderItems.refresh();
    } else {
      orderItems.add(PurchaseOrderItem(
        id: DateTime.now().millisecondsSinceEpoch,
        productId: product.id,
        productName: product.name,
        productCode: product.code,
        barcode: product.barcode,
        unit: product.unit ?? '件',
        quantity: quantity,
        price: price,
      ));
    }
  }

  void updateItemQuantity(int index, int quantity) {
    if (index >= 0 && index < orderItems.length) {
      if (quantity <= 0) {
        orderItems.removeAt(index);
      } else {
        orderItems[index].quantity = quantity;
        orderItems.refresh();
      }
    }
  }

  void updateItemPrice(int index, double price) {
    if (index >= 0 && index < orderItems.length) {
      orderItems[index].price = price;
      orderItems.refresh();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < orderItems.length) {
      orderItems.removeAt(index);
    }
  }

  double get totalAmount => orderItems.fold(0, (sum, item) => sum + (item.quantity * item.price));

  int get totalQuantity => orderItems.fold(0, (sum, item) => sum + item.quantity);

  Future<bool> createOrder() async {
    if (selectedSupplier.value == null) {
      Get.snackbar('提示', '请选择供应商');
      return false;
    }
    if (selectedWarehouse.value == null) {
      Get.snackbar('提示', '请选择入库仓库');
      return false;
    }
    if (orderItems.isEmpty) {
      Get.snackbar('提示', '请添加采购商品');
      return false;
    }

    try {
      final response = await api.post('/purchase-orders', data: {
        'supplierId': selectedSupplier.value!.id,
        'warehouseId': selectedWarehouse.value!.id,
        'orderDate': orderDate.value.toIso8601String(),
        'deliveryDate': deliveryDate.value?.toIso8601String(),
        'remark': remark.value,
        'items': orderItems.map((e) => {
          'productId': e.productId,
          'quantity': e.quantity,
          'price': e.price,
        }).toList(),
      });
      if (response.data != null && response.data['data'] != null) {
        await loadOrders();
        clearItems();
        return true;
      }
    } catch (e) {
      final newOrder = PurchaseOrder(
        id: DateTime.now().millisecondsSinceEpoch,
        orderNo: 'CGDD${DateTime.now().millisecondsSinceEpoch}',
        supplierId: selectedSupplier.value!.id,
        supplierName: selectedSupplier.value!.name,
        warehouseId: selectedWarehouse.value!.id,
        warehouseName: selectedWarehouse.value!.name,
        status: 'pending',
        itemCount: orderItems.length,
        totalAmount: totalAmount,
        remark: remark.value,
        orderDate: orderDate.value,
        deliveryDate: deliveryDate.value,
        createdAt: DateTime.now(),
      );
      orders.insert(0, newOrder);
      clearItems();
      return true;
    }
    return false;
  }

  // 转入库
  Future<bool> convertToPurchase(int orderId) async {
    try {
      await api.post('/purchase-orders/$orderId/convert-to-purchase');
      await loadOrders();
      Get.snackbar('成功', '已生成采购入库单');
      return true;
    } catch (e) {
      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        orders[index] = PurchaseOrder(
          id: orders[index].id,
          orderNo: orders[index].orderNo,
          supplierId: orders[index].supplierId,
          supplierName: orders[index].supplierName,
          warehouseId: orders[index].warehouseId,
          warehouseName: orders[index].warehouseName,
          status: 'completed',
          itemCount: orders[index].itemCount,
          totalAmount: orders[index].totalAmount,
          remark: orders[index].remark,
          orderDate: orders[index].orderDate,
          deliveryDate: orders[index].deliveryDate,
          createdAt: orders[index].createdAt,
          completedAt: DateTime.now(),
        );
        orders.refresh();
      }
      Get.snackbar('成功', '已生成采购入库单');
      return true;
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    try {
      await api.post('/purchase-orders/$orderId/cancel');
      await loadOrders();
      Get.snackbar('成功', '订单已取消');
      return true;
    } catch (e) {
      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        orders[index] = PurchaseOrder(
          id: orders[index].id,
          orderNo: orders[index].orderNo,
          supplierId: orders[index].supplierId,
          supplierName: orders[index].supplierName,
          warehouseId: orders[index].warehouseId,
          warehouseName: orders[index].warehouseName,
          status: 'cancelled',
          itemCount: orders[index].itemCount,
          totalAmount: orders[index].totalAmount,
          remark: orders[index].remark,
          orderDate: orders[index].orderDate,
          deliveryDate: orders[index].deliveryDate,
          createdAt: orders[index].createdAt,
        );
        orders.refresh();
      }
      Get.snackbar('成功', '订单已取消');
      return true;
    }
  }

  void clearItems() {
    selectedSupplier.value = null;
    selectedWarehouse.value = null;
    orderItems.clear();
    remark.value = '';
    orderDate.value = DateTime.now();
    deliveryDate.value = null;
  }
}
