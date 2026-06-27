import 'package:get/get.dart';
import '../../../core/base/base_order_controller.dart';
import '../../../core/contracts/order_contracts.dart';
import '../../../core/strategies/order_strategies.dart';
import '../../../data/models/unified_order_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/warehouse_model.dart';
import '../../../services/api_service.dart';

/// 统一调拨单控制器 - 基于BaseOrderController
class UnifiedTransferOrderController extends BaseOrderController<UnifiedOrder, OrderItem> {
  UnifiedTransferOrderController() : super(api: Get.find<ApiService>());

  // 特定状态
  final fromWarehouse = Rxn<Warehouse>();
  final toWarehouse = Rxn<Warehouse>();

  @override
  OrderType get orderType => OrderType.transfer;

  @override
  String get apiBasePath => '/transfers';

  @override
  UnifiedOrder parseOrder(dynamic json) => UnifiedOrder.fromJson(json);

  @override
  OrderItem parseItem(dynamic json) => OrderItem.fromJson(json);

  @override
  ValidationResult validateOrder() {
    final context = OrderContext(
      type: orderType,
      warehouseId: fromWarehouse.value?.id,
      targetWarehouseId: toWarehouse.value?.id,
      remark: remark.value,
    );
    return OrderStrategyFactory.createValidator(orderType)
        .validate(context, orderItems);
  }

  @override
  Map<String, dynamic> buildOrderData() => {
    'fromWarehouseId': fromWarehouse.value!.id,
    'toWarehouseId': toWarehouse.value!.id,
    'remark': remark.value,
    'items': orderItems.map((e) => {
      'productId': e.productId,
      'quantity': e.quantity,
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
    fromWarehouse.value = null;
    toWarehouse.value = null;
  }

  @override
  void updateOrderStatusAt(int index, OrderStatus status) {
    orders[index] = orders[index].withStatus(status);
  }

  @override
  List<UnifiedOrder> generateMockData() => [
    UnifiedOrder(
      id: 1,
      orderNo: 'DB20240627001',
      orderType: OrderType.transfer,
      status: OrderStatus.completed,
      sourceWarehouseId: 1,
      sourceWarehouseName: '默认仓库',
      targetWarehouseId: 2,
      targetWarehouseName: '分仓',
      totalAmount: 2500.0,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      completedAt: DateTime.now().subtract(const Duration(days: 2)),
      remark: '补货',
    ),
  ];

  @override
  UnifiedOrder createMockOrder() => UnifiedOrder(
    id: DateTime.now().millisecondsSinceEpoch,
    orderNo: 'DB${DateTime.now().millisecondsSinceEpoch}',
    orderType: OrderType.transfer,
    status: OrderStatus.pending,
    sourceWarehouseId: fromWarehouse.value!.id,
    sourceWarehouseName: fromWarehouse.value!.name,
    targetWarehouseId: toWarehouse.value!.id,
    targetWarehouseName: toWarehouse.value!.name,
    totalAmount: 0,
    createdAt: DateTime.now(),
    remark: remark.value,
  );

  // 特定方法
  void selectFromWarehouse(Warehouse warehouse) => fromWarehouse.value = warehouse;
  void selectToWarehouse(Warehouse warehouse) => toWarehouse.value = warehouse;

  /// 确认调拨
  Future<bool> confirmTransfer(int orderId) async {
    return await completeOrder(orderId);
  }
}
