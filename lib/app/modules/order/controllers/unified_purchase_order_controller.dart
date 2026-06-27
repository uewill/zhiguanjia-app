import 'package:get/get.dart';
import '../../../core/base/base_order_controller.dart';
import '../../../core/contracts/order_contracts.dart';
import '../../../core/strategies/order_strategies.dart';
import '../../../data/models/unified_order_model.dart';
import '../../../data/models/supplier_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/warehouse_model.dart';
import '../../../services/api_service.dart';

/// 统一采购单控制器 - 基于BaseOrderController
class UnifiedPurchaseOrderController extends BaseOrderController<UnifiedOrder, OrderItem> {
  UnifiedPurchaseOrderController() : super(api: Get.find<ApiService>());

  // 特定状态
  final selectedSupplier = Rxn<Supplier>();
  final selectedWarehouse = Rxn<Warehouse>();

  @override
  OrderType get orderType => OrderType.purchase;

  @override
  String get apiBasePath => '/purchase-orders';

  @override
  UnifiedOrder parseOrder(dynamic json) => UnifiedOrder.fromJson(json);

  @override
  OrderItem parseItem(dynamic json) => OrderItem.fromJson(json);

  @override
  ValidationResult validateOrder() {
    final context = OrderContext(
      type: orderType,
      warehouseId: selectedWarehouse.value?.id,
      partnerId: selectedSupplier.value?.id,
      partnerName: selectedSupplier.value?.name,
      remark: remark.value,
    );
    return OrderStrategyFactory.createValidator(orderType)
        .validate(context, orderItems);
  }

  @override
  Map<String, dynamic> buildOrderData() => {
    'supplierId': selectedSupplier.value!.id,
    'warehouseId': selectedWarehouse.value!.id,
    'businessDate': businessDate.value.toIso8601String(),
    'expectedDate': expectedDate.value?.toIso8601String(),
    'remark': remark.value,
    'items': orderItems.map((e) => {
      'productId': e.productId,
      'quantity': e.quantity,
      'price': e.price,
    }).toList(),
  };

  @override
  void addOrderItem(OrderItem item) {
    final existingIndex = orderItems.indexWhere((i) => i.productId == item.productId);
    if (existingIndex != -1) {
      orderItems[existingIndex] = orderItems[existingIndex].copyWith(
        quantity: orderItems[existingIndex].quantity + item.quantity,
      );
      orderItems.refresh();
    } else {
      orderItems.add(item);
    }
  }

  @override
  void updateItemAt(int index, double quantity) {
    orderItems[index] = orderItems[index].copyWith(quantity: quantity);
  }

  @override
  void clearSpecificFields() {
    selectedSupplier.value = null;
    selectedWarehouse.value = null;
  }

  @override
  void updateOrderStatusAt(int index, OrderStatus status) {
    orders[index] = orders[index].withStatus(status);
  }

  @override
  List<UnifiedOrder> generateMockData() => [
    UnifiedOrder(
      id: 1,
      orderNo: 'CGDD20240627001',
      orderType: OrderType.purchase,
      status: OrderStatus.completed,
      partnerId: 1,
      partnerName: '供应商A',
      warehouseId: 1,
      warehouseName: '默认仓库',
      totalAmount: 5000.0,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      completedAt: DateTime.now().subtract(const Duration(days: 2)),
      remark: '常规采购',
    ),
    UnifiedOrder(
      id: 2,
      orderNo: 'CGDD20240627002',
      orderType: OrderType.purchase,
      status: OrderStatus.pending,
      partnerId: 2,
      partnerName: '供应商B',
      warehouseId: 1,
      warehouseName: '默认仓库',
      totalAmount: 2500.0,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  UnifiedOrder createMockOrder() => UnifiedOrder(
    id: DateTime.now().millisecondsSinceEpoch,
    orderNo: 'CGDD${DateTime.now().millisecondsSinceEpoch}',
    orderType: OrderType.purchase,
    status: OrderStatus.pending,
    partnerId: selectedSupplier.value!.id,
    partnerName: selectedSupplier.value!.name,
    warehouseId: selectedWarehouse.value!.id,
    warehouseName: selectedWarehouse.value!.name,
    totalAmount: totalAmount,
    createdAt: DateTime.now(),
    remark: remark.value,
  );

  // 特定方法
  void selectSupplier(Supplier supplier) => selectedSupplier.value = supplier;
  void selectWarehouse(Warehouse warehouse) => selectedWarehouse.value = warehouse;

  /// 转入库
  Future<bool> convertToIn(int orderId) async {
    return await completeOrder(orderId);
  }
}
