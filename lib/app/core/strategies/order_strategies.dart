import '../contracts/order_contracts.dart';

/// 单据验证策略接口
abstract class IOrderValidator {
  ValidationResult validate(OrderContext context, List<IOrderItem> items);
}

/// 单据计算策略接口
abstract class IOrderCalculator {
  double calculateAmount(IOrderItem item);
  double calculateTotal(List<IOrderItem> items);
  double calculateTax(double amount, double taxRate);
  double calculateDiscount(double amount, double discountRate);
}

/// 单据编号生成策略接口
abstract class IOrderNoGenerator {
  String generate(OrderType type, {int? warehouseId, DateTime? date});
}

/// 单据状态机策略接口
abstract class IOrderStateMachine {
  bool canTransition(OrderStatus from, OrderAction action);
  OrderStatus? transition(OrderStatus from, OrderAction action);
  List<OrderAction> getAvailableActions(OrderStatus status);
}

// ========== 具体验证策略实现 ==========

/// 商品类单据验证器
class ProductOrderValidator implements IOrderValidator {
  @override
  ValidationResult validate(OrderContext context, List<IOrderItem> items) {
    if (context.warehouseId == null) {
      return ValidationResult.error('请选择仓库');
    }
    if (items.isEmpty) {
      return ValidationResult.error('请添加商品');
    }
    for (var item in items) {
      if (item.quantity <= 0) {
        return ValidationResult.error('${item.productName} 数量必须大于0');
      }
    }
    return ValidationResult.success();
  }
}

/// 销售单验证器
class SaleOrderValidator extends ProductOrderValidator {
  @override
  ValidationResult validate(OrderContext context, List<IOrderItem> items) {
    final base = super.validate(context, items);
    if (!base.isValid) return base;
    
    if (context.partnerId == null) {
      return ValidationResult.error('请选择客户');
    }
    return ValidationResult.success();
  }
}

/// 采购单验证器
class PurchaseOrderValidator extends ProductOrderValidator {
  @override
  ValidationResult validate(OrderContext context, List<IOrderItem> items) {
    final base = super.validate(context, items);
    if (!base.isValid) return base;
    
    if (context.partnerId == null) {
      return ValidationResult.error('请选择供应商');
    }
    return ValidationResult.success();
  }
}

/// 调拨单验证器
class TransferOrderValidator implements IOrderValidator {
  @override
  ValidationResult validate(OrderContext context, List<IOrderItem> items) {
    if (context.warehouseId == null) {
      return ValidationResult.error('请选择调出仓库');
    }
    if (context.targetWarehouseId == null) {
      return ValidationResult.error('请选择调入仓库');
    }
    if (context.warehouseId == context.targetWarehouseId) {
      return ValidationResult.error('调出仓库和调入仓库不能相同');
    }
    if (items.isEmpty) {
      return ValidationResult.error('请添加调拨商品');
    }
    return ValidationResult.success();
  }
}

// ========== 计算策略实现 ==========

/// 标准计算器
class StandardOrderCalculator implements IOrderCalculator {
  @override
  double calculateAmount(IOrderItem item) {
    return item.quantity * (item.price ?? 0);
  }

  @override
  double calculateTotal(List<IOrderItem> items) {
    return items.fold(0, (sum, item) => sum + calculateAmount(item));
  }

  @override
  double calculateTax(double amount, double taxRate) {
    return amount * taxRate;
  }

  @override
  double calculateDiscount(double amount, double discountRate) {
    return amount * discountRate;
  }
}

/// 含税计算器
class TaxInclusiveCalculator implements IOrderCalculator {
  final double taxRate;
  
  TaxInclusiveCalculator({this.taxRate = 0.13});
  
  @override
  double calculateAmount(IOrderItem item) {
    final amount = item.quantity * (item.price ?? 0);
    return amount / (1 + taxRate);
  }

  @override
  double calculateTotal(List<IOrderItem> items) {
    return items.fold(0, (sum, item) => sum + calculateAmount(item));
  }

  @override
  double calculateTax(double amount, double taxRate) {
    return amount * taxRate;
  }

  @override
  double calculateDiscount(double amount, double discountRate) {
    return amount * discountRate;
  }
}

// ========== 单号生成策略 ==========

/// 日期前缀单号生成器
class DatePrefixOrderNoGenerator implements IOrderNoGenerator {
  @override
  String generate(OrderType type, {int? warehouseId, DateTime? date}) {
    final now = date ?? DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final random = now.millisecond.toString().padLeft(3, '0');
    return '${type.prefix}$dateStr$timeStr$random';
  }
}

// ========== 状态机策略 ==========

class DefaultOrderStateMachine implements IOrderStateMachine {
  static final Map<OrderStatus, Map<OrderAction, OrderStatus>> _transitions = {
    OrderStatus.draft: {
      OrderAction.submit: OrderStatus.pending,
      OrderAction.delete: OrderStatus.cancelled,
    },
    OrderStatus.pending: {
      OrderAction.approve: OrderStatus.processing,
      OrderAction.reject: OrderStatus.rejected,
      OrderAction.cancel: OrderStatus.cancelled,
    },
    OrderStatus.processing: {
      OrderAction.complete: OrderStatus.completed,
      OrderAction.cancel: OrderStatus.cancelled,
    },
    OrderStatus.rejected: {
      OrderAction.update: OrderStatus.draft,
    },
  };

  @override
  bool canTransition(OrderStatus from, OrderAction action) {
    return _transitions[from]?.containsKey(action) ?? false;
  }

  @override
  OrderStatus? transition(OrderStatus from, OrderAction action) {
    return _transitions[from]?[action];
  }

  @override
  List<OrderAction> getAvailableActions(OrderStatus status) {
    return _transitions[status]?.keys.toList() ?? [];
  }
}

// ========== 策略工厂 ==========

class OrderStrategyFactory {
  static IOrderValidator createValidator(OrderType type) {
    switch (type) {
      case OrderType.sale:
        return SaleOrderValidator();
      case OrderType.purchase:
        return PurchaseOrderValidator();
      case OrderType.transfer:
        return TransferOrderValidator();
      default:
        return ProductOrderValidator();
    }
  }

  static IOrderCalculator createCalculator({bool taxInclusive = false, double taxRate = 0.13}) {
    if (taxInclusive) {
      return TaxInclusiveCalculator(taxRate: taxRate);
    }
    return StandardOrderCalculator();
  }

  static IOrderNoGenerator createOrderNoGenerator() {
    return DatePrefixOrderNoGenerator();
  }

  static IOrderStateMachine createStateMachine() {
    return DefaultOrderStateMachine();
  }
}
