/// 单据明细项基类
abstract class BillItemBase {
  int? get id;
  int? get productId;
  String get productName;
  String? get productCode;
  String? get unit;
  int get quantity;
  double? get price;
  double? get amount;
  
  Map<String, dynamic> toJson();
}

/// 单据基类 - 所有单据模型的抽象父类
abstract class BillBase {
  int? get id;
  String? get billNo;
  DateTime get billDate;
  String get status;
  String? get remark;
  
  // 合作方信息（采购/销售单用）
  int? get partnerId;
  String? get partnerName;
  
  // 仓库信息
  int? get warehouseId;
  String? get warehouseName;
  
  // 调拨单特有：目标仓库
  int? get toWarehouseId;
  String? get toWarehouseName;
  
  // 金额信息
  double? get totalAmount;
  double? get discountAmount;
  double? get payableAmount;
  double? get paidAmount;
  
  // 明细列表
  List<BillItemBase> get items;
  
  // 转换为JSON
  Map<String, dynamic> toJson();
  
  // 从JSON创建
  static T fromJson<T extends BillBase>(Map<String, dynamic> json) {
    throw UnimplementedError('子类必须实现 fromJson');
  }
}
