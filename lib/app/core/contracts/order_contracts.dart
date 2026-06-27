/// 单据类型枚举
enum OrderType {
  sale('sale', '销售单', 'XSDD'),
  purchase('purchase', '采购单', 'CGDD'),
  transfer('transfer', '调拨单', 'DB'),
  stockIn('stock_in', '入库单', 'RK'),
  stockOut('stock_out', '出库单', 'CK'),
  stockCheck('stock_check', '盘点单', 'PD'),
  adjust('adjust', '调整单', 'TZ'),
  returnIn('return_in', '退货入库', 'THRK'),
  returnOut('return_out', '退货出库', 'THCK');

  final String code;
  final String label;
  final String prefix;

  const OrderType(this.code, this.label, this.prefix);

  static OrderType fromCode(String code) {
    return OrderType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => OrderType.sale,
    );
  }
}

/// 单据状态枚举
enum OrderStatus {
  draft('draft', '草稿', 0xFF999999),
  pending('pending', '待处理', 0xFFFFA500),
  processing('processing', '处理中', 0xFF1890FF),
  completed('completed', '已完成', 0xFF52C41A),
  cancelled('cancelled', '已取消', 0xFFFF4D4F),
  rejected('rejected', '已拒绝', 0xFF722ED1);

  final String code;
  final String label;
  final int colorValue;

  const OrderStatus(this.code, this.label, this.colorValue);

  static OrderStatus fromCode(String code) {
    return OrderStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => OrderStatus.draft,
    );
  }
}

/// 单据动作类型
enum OrderAction {
  create,
  update,
  submit,
  approve,
  reject,
  complete,
  cancel,
  delete,
  convert,
  print,
}

/// 单据项接口 - 所有单据明细必须实现
abstract class IOrderItem {
  int? get id;
  int get productId;
  String get productName;
  String? get productCode;
  String? get barcode;
  String get unit;
  double get quantity;
  double? get price;
  double? get amount;
  Map<String, dynamic> toJson();
}

/// 单据接口 - 所有单据必须实现
abstract class IOrder {
  int? get id;
  String get orderNo;
  OrderType get orderType;
  OrderStatus get status;
  DateTime get createdAt;
  DateTime? get completedAt;
  String? get remark;
  double get totalAmount;
  int get itemCount;
  List<IOrderItem> get items;
  Map<String, dynamic> toJson();
}

/// 单据验证结果
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warnings = const [],
  });

  factory ValidationResult.success() => const ValidationResult(isValid: true);

  factory ValidationResult.error(String message) =>
      ValidationResult(isValid: false, errorMessage: message);

  factory ValidationResult.withWarnings(List<String> warnings) =>
      ValidationResult(isValid: true, warnings: warnings);
}

/// 单据上下文 - 用于传递单据相关信息
class OrderContext {
  final OrderType type;
  final int? warehouseId;
  final int? targetWarehouseId;
  final int? partnerId;
  final String? partnerName;
  final DateTime? businessDate;
  final String? remark;

  const OrderContext({
    required this.type,
    this.warehouseId,
    this.targetWarehouseId,
    this.partnerId,
    this.partnerName,
    this.businessDate,
    this.remark,
  });
}
