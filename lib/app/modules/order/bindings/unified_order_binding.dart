import 'package:get/get.dart';
import '../../../core/contracts/order_contracts.dart';
import '../../../core/factories/order_factory.dart';
import '../controllers/unified_sale_order_controller.dart';
import '../controllers/unified_purchase_order_controller.dart';
import '../controllers/unified_transfer_order_controller.dart';

/// 统一单据绑定 - 根据类型注入对应控制器
class UnifiedOrderBinding extends Bindings {
  final OrderType? orderType;

  UnifiedOrderBinding({this.orderType});

  @override
  void dependencies() {
    final type = orderType ?? _getTypeFromRoute();
    
    switch (type) {
      case OrderType.sale:
        Get.lazyPut(() => UnifiedSaleOrderController());
        break;
      case OrderType.purchase:
        Get.lazyPut(() => UnifiedPurchaseOrderController());
        break;
      case OrderType.transfer:
        Get.lazyPut(() => UnifiedTransferOrderController());
        break;
      default:
        // 默认注入销售单控制器
        Get.lazyPut(() => UnifiedSaleOrderController());
    }
  }

  OrderType _getTypeFromRoute() {
    final route = Get.routing.current;
    if (route.contains('purchase')) return OrderType.purchase;
    if (route.contains('transfer')) return OrderType.transfer;
    return OrderType.sale;
  }
}

/// 统一单据绑定 - 销售单
class SaleOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UnifiedSaleOrderController());
  }
}

/// 统一单据绑定 - 采购单
class PurchaseOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UnifiedPurchaseOrderController());
  }
}

/// 统一单据绑定 - 调拨单
class TransferOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UnifiedTransferOrderController());
  }
}
