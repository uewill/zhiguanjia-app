import 'package:get/get.dart';
import '../../../core/base/base_order_controller.dart';
import '../../../core/contracts/order_contracts.dart';
import '../../../core/strategies/order_strategies.dart';
import '../../../data/models/unified_order_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/warehouse_model.dart';
import '../../../services/api_service.dart';

/// 统一销售单控制器 - 基于BaseOrderController
class UnifiedSaleOrderController extends BaseOrderController<UnifiedOrder, OrderItem> {
  UnifiedSaleOrderController() : super(api: Get.find<ApiService>());

  // 特定状态
  final selectedCustomer = Rxn<Customer>();
  final selectedWarehouse = Rxn<Warehouse>();

  @override
  OrderType get orderType => OrderType.sale;

  @override
  String get apiBasePath => '/sale-orders';

  @override
  UnifiedOrder parseOrder(dynamic json) => UnifiedOrder.fromJson(json);

  @override
  OrderItem parseItem(dynamic json) => OrderItem.fromJson(json);

  @override
  ValidationResult validateOrder() {
    final context = OrderContext(
      type: orderType,
      warehouseId: selectedWarehouse.value?.id,
      partnerId: selectedCustomer.value?.id,
      partnerName: selectedCustomer.value?.name,
      remark: remark.value,
    );
    return OrderStrategyFactory.createValidator(orderType)
        .validate(context, orderItems);
  }

  @override
  Map<String, dynamic> buildOrderData() => {
    'customerId': selectedCustomer.value!.id,
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
    selectedCustomer.value = null;
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
      orderNo: 'XSDD20240627001',
      orderType: OrderType.sale,
      status: OrderStatus.completed,
      partnerId: 1,
      partnerName: '客户A',
      warehouseId: 1,
      warehouseName: '默认仓库',
      totalAmount: 1500.0,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
      remark: '客户自提',
    ),
    UnifiedOrder(
      id: 2,
      orderNo: 'XSDD20240627002',
      orderType: OrderType.sale,
      status: OrderStatus.pending,
      partnerId: 2,
      partnerName: '客户B',
      warehouseId: 1,
      warehouseName: '默认仓库',
      totalAmount: 800.0,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  UnifiedOrder createMockOrder() => UnifiedOrder(
    id: DateTime.now().millisecondsSinceEpoch,
    orderNo: 'XSDD${DateTime.now().millisecondsSinceEpoch}',
    orderType: OrderType.sale,
    status: OrderStatus.pending,
    partnerId: selectedCustomer.value!.id,
    partnerName: selectedCustomer.value!.name,
    warehouseId: selectedWarehouse.value!.id,
    warehouseName: selectedWarehouse.value!.name,
    totalAmount: totalAmount,
    createdAt: DateTime.now(),
    remark: remark.value,
  );

  // 特定方法
  void selectCustomer(Customer customer) => selectedCustomer.value = customer;
  void selectWarehouse(Warehouse warehouse) => selectedWarehouse.value = warehouse;

  /// 转出库
  Future<bool> convertToOut(int orderId) async {
    return await completeOrder(orderId);
  }
}
