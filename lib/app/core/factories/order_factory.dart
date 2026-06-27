import 'package:get/get.dart';
import '../../core/contracts/order_contracts.dart';
import '../../core/base/base_order_controller.dart';
import '../../data/models/unified_order_model.dart';
import '../../modules/order/controllers/unified_sale_order_controller.dart';
import '../../modules/order/controllers/unified_purchase_order_controller.dart';
import '../../modules/order/controllers/unified_transfer_order_controller.dart';

/// 单据控制器工厂
class OrderControllerFactory {
  static BaseOrderController<UnifiedOrder, OrderItem> createController(OrderType type) {
    switch (type) {
      case OrderType.sale:
        return UnifiedSaleOrderController();
      case OrderType.purchase:
        return UnifiedPurchaseOrderController();
      case OrderType.transfer:
        return UnifiedTransferOrderController();
      default:
        throw Exception('不支持的单据类型: ${type.code}');
    }
  }

  static String getRouteForType(OrderType type) {
    switch (type) {
      case OrderType.sale:
        return '/sale-orders';
      case OrderType.purchase:
        return '/purchase-orders';
      case OrderType.transfer:
        return '/transfers';
      default:
        return '/orders';
    }
  }

  static String getTitleForType(OrderType type) {
    return type.label;
  }
}

/// 单据服务工厂 - 用于获取服务实例
class OrderServiceFactory {
  /// 根据单据类型获取对应的验证器
  static dynamic createValidator(OrderType type) {
    // 使用 OrderStrategyFactory
    return null; // 实际使用时导入 OrderStrategyFactory
  }

  /// 根据单据类型获取对应的计算器
  static dynamic createCalculator({bool taxInclusive = false}) {
    return null; // 实际使用时导入 OrderStrategyFactory
  }
}
